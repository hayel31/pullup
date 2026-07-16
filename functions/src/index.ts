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
    if (event.hostId !== uid) throw new HttpsError("permission-denied", "Only host can accept.");
    if (joinRequest.status !== "pending") throw new HttpsError("failed-precondition", "Request is not pending.");
    if ((event.availableSpots ?? 0) < joinRequest.groupSize) {
      throw new HttpsError("failed-precondition", "Not enough spots.");
    }

    const matchRef = db.collection("matches").doc();
    const conversationRef = db.collection("conversations").doc();
    const participantRef = eventRef.collection("participants").doc(joinRequest.requesterId);
    const remaining = event.availableSpots - joinRequest.groupSize;

    tx.update(requestRef, {status: "accepted", decidedAt: admin.firestore.FieldValue.serverTimestamp()});
    tx.update(eventRef, {
      acceptedParticipantIds: admin.firestore.FieldValue.arrayUnion(joinRequest.requesterId),
      waitingParticipantIds: admin.firestore.FieldValue.arrayRemove(joinRequest.requesterId),
      availableSpots: remaining,
      matchCount: admin.firestore.FieldValue.increment(1),
      status: remaining === 0 ? "full" : event.status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    tx.set(participantRef, {
      userId: joinRequest.requesterId,
      groupSize: joinRequest.groupSize,
      acceptedAt: admin.firestore.FieldValue.serverTimestamp()
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
      memberIds: [joinRequest.requesterId, uid],
      lastMessagePreview: "Exact address unlocked.",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      unreadByUserIds: [joinRequest.requesterId]
    });
    tx.set(conversationRef.collection("messages").doc(), {
      senderId: "system",
      type: "system",
      text: "Match created. Exact address is now available in the event.",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readByUserIds: [uid]
    });

    return {matchId: matchRef.id, conversationId: conversationRef.id};
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
