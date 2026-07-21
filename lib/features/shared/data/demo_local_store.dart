import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/party_event.dart';
import '../../../models/user_profile.dart';

class DemoPersistedData {
  const DemoPersistedData({
    required this.users,
    required this.events,
    required this.credentials,
    required this.sessionUserId,
  });

  const DemoPersistedData.empty()
    : users = const [],
      events = const [],
      credentials = const [],
      sessionUserId = null;

  final List<UserProfile> users;
  final List<PartyEvent> events;
  final List<StoredCredential> credentials;
  final String? sessionUserId;
}

class StoredCredential {
  const StoredCredential({
    required this.userId,
    required this.email,
    required this.salt,
    required this.passwordDigest,
  });

  final String userId;
  final String email;
  final String salt;
  final String passwordDigest;

  bool matches(String candidate) {
    return _digest(candidate, salt) == passwordDigest;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'salt': salt,
    'passwordDigest': passwordDigest,
  };

  factory StoredCredential.fromJson(Map<String, dynamic> json) {
    return StoredCredential(
      userId: json['userId'] as String,
      email: json['email'] as String,
      salt: json['salt'] as String,
      passwordDigest: json['passwordDigest'] as String,
    );
  }

  factory StoredCredential.create({
    required String userId,
    required String email,
    required String password,
  }) {
    final salt = '$userId-${DateTime.now().microsecondsSinceEpoch}';
    return StoredCredential(
      userId: userId,
      email: email.toLowerCase().trim(),
      salt: salt,
      passwordDigest: _digest(password, salt),
    );
  }

  static String _digest(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}

class DemoLocalStore {
  static const _usersKey = 'pullup.demo.users.v1';
  static const _eventsKey = 'pullup.demo.events.v1';
  static const _credentialsKey = 'pullup.demo.credentials.v1';
  static const _sessionKey = 'pullup.demo.session.v1';

  Future<DemoPersistedData> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return DemoPersistedData(
        users: _decodeList(
          preferences.getString(_usersKey),
          UserProfile.fromJson,
        ),
        events: _decodeList(
          preferences.getString(_eventsKey),
          PartyEvent.fromJson,
        ),
        credentials: _decodeList(
          preferences.getString(_credentialsKey),
          StoredCredential.fromJson,
        ),
        sessionUserId: preferences.getString(_sessionKey),
      );
    } catch (_) {
      return const DemoPersistedData.empty();
    }
  }

  Future<void> saveUser(UserProfile user) async {
    await _mutateList(
      key: _usersKey,
      identify: (item) => item['id'] as String,
      id: user.id,
      value: user.toJson(),
    );
  }

  Future<void> saveEvent(PartyEvent event) async {
    await _mutateList(
      key: _eventsKey,
      identify: (item) => item['id'] as String,
      id: event.id,
      value: event.toJson(includePrivateAddress: true),
    );
  }

  Future<void> saveCredential(StoredCredential credential) async {
    await _mutateList(
      key: _credentialsKey,
      identify: (item) => (item['email'] as String).toLowerCase(),
      id: credential.email.toLowerCase(),
      value: credential.toJson(),
    );
  }

  Future<void> saveSession(String userId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_sessionKey, userId);
    } catch (_) {
      // The in-memory demo remains usable when persistence is unavailable.
    }
  }

  Future<void> clearSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_sessionKey);
    } catch (_) {
      // The in-memory demo remains usable when persistence is unavailable.
    }
  }

  Future<void> _mutateList({
    required String key,
    required String Function(Map<String, dynamic> item) identify,
    required String id,
    required Map<String, dynamic> value,
  }) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final current = _decodeMaps(preferences.getString(key));
      final index = current.indexWhere((item) => identify(item) == id);
      if (index == -1) {
        current.add(value);
      } else {
        current[index] = value;
      }
      await preferences.setString(key, jsonEncode(current));
    } catch (_) {
      // The in-memory demo remains usable when persistence is unavailable.
    }
  }

  static List<Map<String, dynamic>> _decodeMaps(String? value) {
    if (value == null || value.isEmpty) return [];
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static List<T> _decodeList<T>(
    String? value,
    T Function(Map<String, dynamic> json) decode,
  ) {
    return _decodeMaps(value).map(decode).toList();
  }
}
