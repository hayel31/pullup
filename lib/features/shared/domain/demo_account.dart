class DemoAccount {
  const DemoAccount({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.password,
    required this.eventLabel,
  });

  final String userId;
  final String displayName;
  final String email;
  final String password;
  final String eventLabel;
}

const demoAccounts = <DemoAccount>[
  DemoAccount(
    userId: 'host-001',
    displayName: 'Leo',
    email: 'leo@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Rooftop & loft host',
  ),
  DemoAccount(
    userId: 'host-002',
    displayName: 'Jade',
    email: 'jade@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Pool & apartment host',
  ),
  DemoAccount(
    userId: 'host-003',
    displayName: 'Noah',
    email: 'noah@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Boat & villa host',
  ),
  DemoAccount(
    userId: 'dj-001',
    displayName: 'Nina Volt',
    email: 'nina@pullup.demo',
    password: 'Pullup2026!',
    eventLabel: 'Private DJ event host',
  ),
];
