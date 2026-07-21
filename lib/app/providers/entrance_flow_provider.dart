import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ephemeral navigation state. It resets on every app or browser launch so a
/// restored `/welcome` URL cannot bypass the pre-login entrance animation.
final preLoginEntranceSeenProvider = StateProvider<bool>((ref) => false);
