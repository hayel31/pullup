import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

admin.initializeApp();
const db = admin.firestore();

export const createMatchFromAcceptedRequest = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const {eventId, requestId} = request.data as {eventId: string; requestId: string};
  if (!eventId || !requestId) throw new HttpsError("invalid-argument", "eventId and requestId are required.");

  return db.runTransaction(async (tx) => {
    const eventRef = db.doc(`events/${eventId}`);
    const requestRef = db.doc(`events/${eventId}/requests/${requestId}`);
    const eventSnap = await tx.get(eventRef);
    const requestSnap = await tx.get(requestRef);
    if (!eventSnap.exists || !requestSnap.exists) throw new HttpsError("not-found", "Event or request missing.");

    const event = eventSnap.data()!;
    const joinRequest = requestSnap.data()!;
    const isProfessionalService =
      joinRequest.kind === "professionalService";
    const reservedSpots = isProfessionalService ? 0 : Number(joinRequest.groupSize);
    if (event.hostId !== uid) throw new HttpsError("permission-denied", "Only host can accept.");
    if (joinRequest.status !== "pending") throw new HttpsError("failed-precondition", "Request is not pending.");
    if ((event.availableSpots ?? 0) < reservedSpots) {
      throw new HttpsError("failed-precondition", "Not enough spots.");
    }
    const companionUserIds = isProfessionalService ? [] : [
      ...new Set((joinRequest.companionUserIds ?? []) as string[])
    ];
    const guestMenCount = Number(joinRequest.guestMenCount ?? 0);
    const guestWomenCount = Number(joinRequest.guestWomenCount ?? 0);
    const companionNames = (joinRequest.companionNames ?? []) as string[];
    const identifiedGuestIds = [
      joinRequest.requesterId,
      ...companionUserIds
    ];
    const expectedGroupSize =
      1 +
      companionUserIds.length +
      companionNames.length +
      guestMenCount +
      guestWomenCount;
    if (!isProfessionalService &&
      (
      expectedGroupSize !== Number(joinRequest.groupSize) ||
      guestMenCount < 0 ||
      guestWomenCount < 0
      )) {
      throw new HttpsError(
        "failed-precondition",
        "Group details do not match the requested capacity."
      );
    }
    if (!isProfessionalService &&
      (
      companionUserIds.includes(uid) ||
      companionUserIds.includes(joinRequest.requesterId)
      )) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid companion in this request."
      );
    }
    if (isProfessionalService) {
      const professionalSnap = await tx.get(
        db.doc(`users/${joinRequest.requesterId}`)
      );
      const professional = professionalSnap.data();
      const category = professional?.professionalProfile?.category;
      const eventNeeds = (event.professionalNeeds ?? []) as string[];
      if (
        !professionalSnap.exists ||
        professional?.accountType !== "professional" ||
        category !== joinRequest.professionalCategory ||
        !eventNeeds.includes(category)
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Professional profile does not match this event need."
        );
      }
    }
    for (const companionId of companionUserIds) {
      const friendship = await tx.get(
        db.doc(`users/${joinRequest.requesterId}/friends/${companionId}`)
      );
      if (!friendship.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Every identified companion must be a confirmed friend."
        );
      }
    }
    let acceptedMenCount = 0;
    let acceptedWomenCount = 0;
    let acceptedOtherCount = 0;
    if (!isProfessionalService) {
      acceptedMenCount = guestMenCount;
      acceptedWomenCount = guestWomenCount;
      acceptedOtherCount = companionNames.length;
      const guestProfiles = await Promise.all(
        identifiedGuestIds.map((guestId) =>
          tx.get(db.doc(`users/${guestId}`))
        )
      );
      guestProfiles.forEach((profileSnap) => {
        const gender = profileSnap.data()?.gender;
        if (gender === "man") {
          acceptedMenCount += 1;
        } else if (gender === "woman") {
          acceptedWomenCount += 1;
        } else {
          acceptedOtherCount += 1;
        }
      });
      const unclassified =
        reservedSpots -
        acceptedMenCount -
        acceptedWomenCount -
        acceptedOtherCount;
      if (unclassified > 0) acceptedOtherCount += unclassified;
    }

    const matchRef = db.collection("matches").doc();
    const conversationRef = db.collection("conversations").doc();
    const memberIds = [uid, ...identifiedGuestIds];
    const remaining = event.availableSpots - reservedSpots;
    const existingAttendance = event.attendance ?? {};
    const occupiedFallback = Math.max(
      0,
      Number(event.maxParticipants ?? 0) - Number(event.availableSpots ?? 0)
    );
    const currentMenCount = Number(
      existingAttendance.currentMenCount ?? 0
    );
    const currentWomenCount = Number(
      existingAttendance.currentWomenCount ?? 0
    );
    const currentOtherCount = Number(
      existingAttendance.currentOtherCount ??
      (
        currentMenCount + currentWomenCount === 0 ?
          occupiedFallback :
          0
      )
    );
    const nextAttendance = {
      initialMenCount: Number(existingAttendance.initialMenCount ?? 0),
      initialWomenCount: Number(existingAttendance.initialWomenCount ?? 0),
      initialOtherCount: Number(
        existingAttendance.initialOtherCount ?? occupiedFallback
      ),
      currentMenCount: currentMenCount + acceptedMenCount,
      currentWomenCount: currentWomenCount + acceptedWomenCount,
      currentOtherCount: currentOtherCount + acceptedOtherCount
    };
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + 12 * 60 * 60 * 1000
    );

    tx.update(requestRef, {status: "accepted", decidedAt: admin.firestore.FieldValue.serverTimestamp()});
    tx.update(eventRef, {
      acceptedParticipantIds: admin.firestore.FieldValue.arrayUnion(
        ...identifiedGuestIds
      ),
      waitingParticipantIds: admin.firestore.FieldValue.arrayRemove(joinRequest.requesterId),
      availableSpots: remaining,
      attendance: nextAttendance,
      matchCount: admin.firestore.FieldValue.increment(1),
      status: reservedSpots > 0 && remaining === 0 ? "full" : event.status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    identifiedGuestIds.forEach((guestId) => {
      tx.set(eventRef.collection("participants").doc(guestId), {
        userId: guestId,
        requestId,
        groupSize: reservedSpots,
        requestKind: joinRequest.kind ?? "guest",
        acceptedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
    tx.set(matchRef, {
      userId: joinRequest.requesterId,
      hostId: uid,
      eventId,
      conversationId: conversationRef.id,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isNew: true
    });
    tx.set(conversationRef, {
      eventId,
      memberIds,
      isGroup: true,
      expiresAt,
      lastMessagePreview: isProfessionalService ?
        "Professional connection opened for 12 hours." :
        "Group chat opened for 12 hours.",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      unreadByUserIds: identifiedGuestIds
    });
    tx.set(conversationRef.collection("messages").doc(), {
      senderId: "system",
      type: "system",
      text: isProfessionalService ?
        "Professional application accepted. This chat closes in 12 hours." :
        "Group confirmed. Exact access is available and this chat closes in 12 hours.",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readByUserIds: [uid]
    });

    return {matchId: matchRef.id, conversationId: conversationRef.id};
  });
});

export const setFriendConnection = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const {friendId, connected} = request.data as {
    friendId: string;
    connected: boolean;
  };
  if (!friendId || friendId === uid || typeof connected !== "boolean") {
    throw new HttpsError(
      "invalid-argument",
      "A different friendId and a connection state are required."
    );
  }

  const userRef = db.doc(`users/${uid}`);
  const friendRef = db.doc(`users/${friendId}`);
  const firstConnectionRef = userRef.collection("friends").doc(friendId);
  const secondConnectionRef = friendRef.collection("friends").doc(uid);
  const blockedByUserRef = userRef.collection("blockedUsers").doc(friendId);
  const blockedByFriendRef = friendRef.collection("blockedUsers").doc(uid);

  return db.runTransaction(async (tx) => {
    const [
      user,
      friend,
      blockedByUser,
      blockedByFriend
    ] = await Promise.all([
      tx.get(userRef),
      tx.get(friendRef),
      tx.get(blockedByUserRef),
      tx.get(blockedByFriendRef)
    ]);
    if (!user.exists || !friend.exists) {
      throw new HttpsError("not-found", "User not found.");
    }
    if (blockedByUser.exists || blockedByFriend.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This friend connection is unavailable."
      );
    }

    if (connected) {
      const payload = {
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };
      tx.set(firstConnectionRef, {...payload, userId: friendId});
      tx.set(secondConnectionRef, {...payload, userId: uid});
    } else {
      tx.delete(firstConnectionRef);
      tx.delete(secondConnectionRef);
    }
    return {friendId, connected};
  });
});

export const withdrawEventRequest = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const {eventId, requestId} = request.data as {
    eventId: string;
    requestId: string;
  };
  if (!eventId || !requestId) {
    throw new HttpsError(
      "invalid-argument",
      "eventId and requestId are required."
    );
  }

  return db.runTransaction(async (tx) => {
    const eventRef = db.doc(`events/${eventId}`);
    const requestRef = eventRef.collection("requests").doc(requestId);
    const swipeRef = db.doc(`users/${uid}/swipes/${eventId}`);
    const eventSnap = await tx.get(eventRef);
    const requestSnap = await tx.get(requestRef);
    if (!eventSnap.exists || !requestSnap.exists) {
      throw new HttpsError("not-found", "Event or request missing.");
    }

    const event = eventSnap.data()!;
    const joinRequest = requestSnap.data()!;
    if (joinRequest.requesterId !== uid) {
      throw new HttpsError(
        "permission-denied",
        "You can only withdraw your own request."
      );
    }
    if (joinRequest.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Only pending requests can be withdrawn."
      );
    }

    tx.update(requestRef, {
      status: "withdrawn",
      decidedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    tx.update(eventRef, {
      waitingParticipantIds: admin.firestore.FieldValue.arrayRemove(uid),
      requestCount: Math.max(0, Number(event.requestCount ?? 0) - 1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    tx.delete(swipeRef);

    return {requestId, status: "withdrawn"};
  });
});

export const preventDuplicateRequest = onDocumentCreated("events/{eventId}/requests/{requestId}", async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const siblings = await db
    .collection(`events/${event.params.eventId}/requests`)
    .where("requesterId", "==", data.requesterId)
    .where("status", "in", ["pending", "accepted"])
    .get();
  if (siblings.size > 1) {
    await event.data?.ref.update({status: "rejected", moderatorNotes: "Duplicate request auto-rejected."});
  }
});

export const sendNotificationOnMessage = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message || message.senderId === "system") return;
    const conversation = await db.doc(`conversations/${event.params.conversationId}`).get();
    const memberIds = (conversation.data()?.memberIds ?? []) as string[];
    await Promise.all(
      memberIds
        .filter((userId) => userId !== message.senderId)
        .map((userId) =>
          db.collection(`users/${userId}/notifications`).add({
            type: "newMessage",
            title: "New message",
            body: message.text ?? "New message",
            conversationId: event.params.conversationId,
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
          })
        )
    );
  }
);

export const expireAndTransitionEvents = onSchedule("every 15 minutes", async () => {
  const now = admin.firestore.Timestamp.now();
  const active = await db.collection("events").where("status", "in", ["published", "ongoing", "full"]).get();
  const batch = db.batch();
  active.docs.forEach((doc) => {
    const data = doc.data();
    if (data.expiresAt && data.expiresAt.toMillis() <= now.toMillis()) {
      batch.update(doc.ref, {status: "ended", updatedAt: admin.firestore.FieldValue.serverTimestamp()});
    } else if (data.startDateTime && data.startDateTime.toMillis() <= now.toMillis() && data.status === "published") {
      batch.update(doc.ref, {status: "ongoing", updatedAt: admin.firestore.FieldValue.serverTimestamp()});
    }
  });
  await batch.commit();
});

export const expireGroupConversations = onSchedule(
  "every 15 minutes",
  async () => {
    const expired = await db
      .collection("conversations")
      .where("expiresAt", "<=", admin.firestore.Timestamp.now())
      .limit(100)
      .get();
    await Promise.all(expired.docs.map((doc) => db.recursiveDelete(doc.ref)));
  }
);

export const moderateAfterReportThreshold = onDocumentCreated("reports/{reportId}", async (event) => {
  const report = event.data?.data();
  if (!report?.reportedEventId) return;
  const reports = await db.collection("reports").where("reportedEventId", "==", report.reportedEventId).get();
  if (reports.size >= 5) {
    await db.doc(`events/${report.reportedEventId}`).update({
      status: "suspended",
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
});
