import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    const benefits = [
      'Undo the last swipe',
      'Advanced filters',
      'Message hosts before match',
      'More distance',
      'Priority requests',
      'Incognito discovery mode',
      'See visible likes for hosted events',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('PULLUP Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Move faster tonight',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final benefit in benefits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PullupChip(
                      label: benefit,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly', style: Theme.of(context).textTheme.titleLarge),
                const Text('9.99 EUR / month'),
                const SizedBox(height: 10),
                Text('Annual', style: Theme.of(context).textTheme.titleLarge),
                const Text('79.99 EUR / year'),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Preview Premium',
                  icon: Icons.workspace_premium_rounded,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Premium preview enabled for this session.',
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Restore purchases'),
                ),
                const Text(
                  'No payment is collected in this preview.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
