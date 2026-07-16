import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/age_utils.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/app_drafts.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              AppConstants.signature,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.slogan,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                AppConstants.signature,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Continue as guest demo',
                icon: Icons.nightlife_rounded,
                onPressed: () => controller.signInDemo(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => controller.signInDemo(asHost: true),
                icon: const Icon(Icons.home_work_rounded),
                label: const Text('Continue as host demo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.mail_outline_rounded),
                label: const Text('Sign in with email'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'maya@pullup.demo');
  final _password = TextEditingController(text: 'pullup-demo');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: _AuthLayout(
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Sign in',
              icon: Icons.login_rounded,
              onPressed: () =>
                  ref.read(appControllerProvider.notifier).signInDemo(),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(appControllerProvider.notifier).signInDemo(),
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(appControllerProvider.notifier).signInDemo(),
              icon: const Icon(Icons.apple_rounded),
              label: const Text('Continue with Apple'),
            ),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _displayName = TextEditingController();
  final _city = TextEditingController(text: 'Paris');
  final _email = TextEditingController();
  final _password = TextEditingController();
  DateTime _birthDate = DateTime(2000, 1, 1);
  Gender _gender = Gender.preferNotToSay;
  bool _acceptedTerms = false;
  bool _confirmedAge = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _displayName.dispose();
    _city.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: _AuthLayout(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(
                  labelText: 'Last name optional',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                items: [
                  for (final gender in Gender.values)
                    DropdownMenuItem(value: gender, child: Text(gender.label)),
                ],
                onChanged: (value) =>
                    setState(() => _gender = value ?? _gender),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Birth date'),
                subtitle: Text(
                  '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                ),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: _pickBirthDate,
              ),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => (value ?? '').length < 8
                    ? 'Use at least 8 characters'
                    : null,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _acceptedTerms,
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
                title: const Text('I accept the terms and community rules'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _confirmedAge,
                onChanged: (value) =>
                    setState(() => _confirmedAge = value ?? false),
                title: const Text('I confirm I am at least 18'),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              GradientButton(
                label: 'Create account',
                icon: Icons.person_add_alt_rounded,
                onPressed: state.loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!AgeUtils.isMinimumAge(_birthDate)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PULLUP is 18+ only.')));
      return;
    }
    ref
        .read(appControllerProvider.notifier)
        .register(
          SignUpDraft(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim().isEmpty
                ? null
                : _lastName.text.trim(),
            displayName: _displayName.text.trim(),
            birthDate: _birthDate,
            gender: _gender,
            city: _city.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            acceptedTerms: _acceptedTerms,
            confirmedMinimumAge: _confirmedAge,
          ),
        );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: const _AuthLayout(
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            FilledButton(onPressed: null, child: Text('Send reset link')),
            SizedBox(height: 12),
            Text(
              'Firebase Auth email reset is prepared. Add credentials to enable it.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: _AuthLayout(
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('Email verification is tracked in the profile model.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [NightCard(child: child)],
      ),
    );
  }
}
