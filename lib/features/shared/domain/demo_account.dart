import '../../../models/enums.dart';

class DemoAccount {
  const DemoAccount({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.password,
    required this.eventLabel,
    this.professionalCategory,
  });

  final String userId;
  final String displayName;
  final String email;
  final String password;
  final String eventLabel;
  final ProfessionalCategory? professionalCategory;

  bool get isProfessional => professionalCategory != null;
}

const demoAccounts = <DemoAccount>[
  DemoAccount(
    userId: 'host-001',
    displayName: 'Leo',
    email: 'leo@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Toulouse rooftop & loft host',
  ),
  DemoAccount(
    userId: 'host-002',
    displayName: 'Jade',
    email: 'jade@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Toulouse pool & apartment host',
  ),
  DemoAccount(
    userId: 'host-003',
    displayName: 'Noah',
    email: 'noah@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Toulouse boat & villa host',
  ),
  DemoAccount(
    userId: 'dj-001',
    displayName: 'Nina Volt',
    email: 'nina@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Professional DJ - Toulouse',
    professionalCategory: ProfessionalCategory.dj,
  ),
  DemoAccount(
    userId: 'pro-bar-001',
    displayName: 'Le Halo Toulouse',
    email: 'halo@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Professional bar & venue - Toulouse',
    professionalCategory: ProfessionalCategory.bar,
  ),
];
