import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/providers/entrance_flow_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/age_utils.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/pullup_logo.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/portal_entrance_animation.dart';
import '../widgets/welcome_experience.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _completed = false;

  Future<void> _completeSplash() async {
    if (_completed) return;
    _completed = true;
    await ref.read(appControllerProvider.notifier).ready;
    if (!mounted) return;
    final user = ref.read(appControllerProvider).currentUser;
    if (user == null) {
      ref.read(preLoginEntranceSeenProvider.notifier).state = true;
      context.go('/welcome');
      return;
    }
    context.go(user.onboardingCompleted ? '/discover' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) => PortalEntranceAnimation(
    phase: PortalEntrancePhase.beforeSignIn,
    onCompleted: _completeSplash,
  );
}

class PostLoginEntrancePage extends ConsumerStatefulWidget {
  const PostLoginEntrancePage({super.key});

  @override
  ConsumerState<PostLoginEntrancePage> createState() =>
      _PostLoginEntrancePageState();
}

class _PostLoginEntrancePageState extends ConsumerState<PostLoginEntrancePage> {
  bool _completed = false;

  void _continue() {
    if (_completed || !mounted) return;
    _completed = true;
    final user = ref.read(appControllerProvider).currentUser;
    context.go(
      user == null
          ? '/welcome'
          : user.onboardingCompleted
          ? '/discover'
          : '/onboarding',
    );
  }

  @override
  Widget build(BuildContext context) => PortalEntranceAnimation(
    phase: PortalEntrancePhase.afterSignIn,
    onCompleted: _continue,
  );
}

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    return WelcomeExperience(
      onSignIn: (email, password) =>
          controller.signIn(email: email, password: password),
      onCreateAccount: () => context.go('/register'),
      onForgotPassword: () => context.go('/forgot-password'),
      isLoading: state.loading,
      errorMessage: state.errorMessage,
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'leo@pullup.demo');
  final _password = TextEditingController(text: 'Pullup2026!');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return ref
        .read(appControllerProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PullupBrand(logoSize: 28)),
      body: _AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthIntro(
              icon: Icons.login_rounded,
              title: 'Welcome back',
              message: 'Sign in to pick up where your night left off.',
            ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: context.tr('Email address'),
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.tr('Password'),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: context.tr(
                    _obscurePassword ? 'Show password' : 'Hide password',
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Sign in',
              icon: Icons.login_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.g_mobiledata_rounded),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.apple_rounded),
              label: const Text('Continue with Apple'),
            ),
            const SizedBox(height: 2),
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
  bool _obscurePassword = true;

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
      appBar: AppBar(title: const PullupBrand(logoSize: 28)),
      body: _AuthLayout(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthIntro(
                icon: Icons.person_add_alt_rounded,
                title: 'Create your profile',
                message:
                    'A clear profile helps hosts make confident decisions.',
              ),
              TextFormField(
                controller: _firstName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr('First name'),
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                decoration: InputDecoration(
                  labelText: context.tr('Last name'),
                  helperText: context.tr('Optional'),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayName,
                decoration: InputDecoration(
                  labelText: context.tr('Name shown on PULLUP'),
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                isExpanded: true,
                items: [
                  for (final gender in Gender.values)
                    DropdownMenuItem(value: gender, child: Text(gender.label)),
                ],
                onChanged: (value) =>
                    setState(() => _gender = value ?? _gender),
                decoration: InputDecoration(
                  labelText: context.tr('How do you identify?'),
                  prefixIcon: Icon(Icons.people_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.tr('Date of birth'),
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_birthDate.day.toString().padLeft(2, '0')}/'
                          '${_birthDate.month.toString().padLeft(2, '0')}/'
                          '${_birthDate.year}',
                        ),
                      ),
                      const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _city,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr('City'),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: context.tr('Email address'),
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: context.tr('Create a password'),
                  helperText: context.tr('Use at least 8 characters'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: context.tr(
                      _obscurePassword ? 'Show password' : 'Hide password',
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value ?? '').length < 8
                    ? context.tr('Password must contain at least 8 characters')
                    : null,
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _acceptedTerms,
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
                title: const Text(
                  'I accept the Terms of Use and Community Guidelines.',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _confirmedAge,
                onChanged: (value) =>
                    setState(() => _confirmedAge = value ?? false),
                title: const Text('I confirm that I am at least 18 years old.'),
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
      value == null || value.trim().isEmpty ? context.tr('Required') : null;

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
    if (!_acceptedTerms || !_confirmedAge) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept the terms and confirm your age to continue.'),
        ),
      );
      return;
    }
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
      appBar: AppBar(title: const PullupBrand(logoSize: 28)),
      body: _AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthIntro(
              icon: Icons.lock_reset_rounded,
              title: 'Reset your password',
              message: 'We will send a secure reset link to your email.',
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email],
              decoration: InputDecoration(
                labelText: context.tr('Email address'),
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check your inbox for the reset link.'),
                ),
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send reset link'),
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
      appBar: AppBar(title: const PullupBrand(logoSize: 28)),
      body: _AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthIntro(
              icon: Icons.mark_email_read_outlined,
              title: 'Verify your email',
              message: 'Open the link we sent to secure your PULLUP account.',
            ),
            FilledButton(
              onPressed: () => context.go('/discover'),
              child: const Text('I have verified my email'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () {}, child: const Text('Resend email')),
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthIntro extends StatelessWidget {
  const _AuthIntro({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: AppColors.magenta),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
