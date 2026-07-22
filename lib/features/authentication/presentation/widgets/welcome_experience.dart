import 'dart:async';

import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/language_picker_button.dart';
import '../../../../core/widgets/pullup_logo.dart';
import '../../../../core/widgets/theme_preset_selector.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/demo_account.dart';

enum _AuthEntryMode { signIn, register }

class WelcomeExperience extends ConsumerStatefulWidget {
  const WelcomeExperience({
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onForgotPassword,
    required this.isLoading,
    required this.errorMessage,
    super.key,
  });

  final Future<void> Function(String email, String password) onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;
  final bool isLoading;
  final String? errorMessage;

  @override
  ConsumerState<WelcomeExperience> createState() => _WelcomeExperienceState();
}

class _WelcomeExperienceState extends ConsumerState<WelcomeExperience> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  _AuthEntryMode _mode = _AuthEntryMode.signIn;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await widget.onSignIn(_email.text.trim(), _password.text);
  }

  void _selectDemoAccount(DemoAccount account) {
    _email.text = account.email;
    _password.text = account.password;
    setState(() => _mode = _AuthEntryMode.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 40).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _AuthTopBar(),
                        const SizedBox(height: 48),
                        const _Entrance(
                          delay: Duration(milliseconds: 150),
                          child: _AuthHero(),
                        ),
                        const SizedBox(height: 22),
                        const _Entrance(
                          delay: Duration(milliseconds: 220),
                          child: ThemePresetSelector(),
                        ),
                        const SizedBox(height: 22),
                        _Entrance(
                          delay: const Duration(milliseconds: 300),
                          child: _AuthModeSelector(
                            mode: _mode,
                            onChanged: (mode) => setState(() => _mode = mode),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _Entrance(
                          delay: const Duration(milliseconds: 400),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _mode == _AuthEntryMode.signIn
                                ? _SignInPanel(
                                    key: const ValueKey('sign-in-panel'),
                                    email: _email,
                                    password: _password,
                                    obscurePassword: _obscurePassword,
                                    isLoading: widget.isLoading,
                                    errorMessage: widget.errorMessage,
                                    onTogglePassword: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    onSubmit: _submit,
                                    onForgotPassword: widget.onForgotPassword,
                                    onSelectDemoAccount: _selectDemoAccount,
                                  )
                                : _RegisterPanel(
                                    key: const ValueKey('register-panel'),
                                    onCreateAccount: widget.onCreateAccount,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -86,
            right: -106,
            width: 360,
            height: 360,
            child: Opacity(
              opacity: 0.24,
              child: Image.asset(
                PullupLogo.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                excludeFromSemantics: true,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primary.withValues(alpha: 0.32),
                  AppColors.background.withValues(alpha: 0.18),
                  AppColors.background,
                ],
                stops: [0, 0.42, 0.82],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PullupBrand(logoSize: 36, logoHeroTag: PullupLogo.splashHeroTag),
        const Spacer(),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: AppColors.magenta.withValues(alpha: 0.48),
            ),
          ),
          child: const Text(
            '18+',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const LanguagePickerButton(),
        ),
      ],
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('welcome-hero'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Your night starts here.'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          context.tr(
            'Sign in, discover the right plan, then switch to host mode whenever you need it.',
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBright, AppColors.magenta],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                AppConstants.signature,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthModeSelector extends StatelessWidget {
  const _AuthModeSelector({required this.mode, required this.onChanged});

  final _AuthEntryMode mode;
  final ValueChanged<_AuthEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _AuthModeButton(
            key: const Key('auth-mode-sign-in'),
            label: context.tr('Sign in'),
            icon: Icons.login_rounded,
            selected: mode == _AuthEntryMode.signIn,
            onTap: () => onChanged(_AuthEntryMode.signIn),
          ),
          _AuthModeButton(
            key: const Key('auth-mode-register'),
            label: context.tr('Create account'),
            icon: Icons.person_add_alt_rounded,
            selected: mode == _AuthEntryMode.register,
            onTap: () => onChanged(_AuthEntryMode.register),
          ),
        ],
      ),
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(
                    color: AppColors.primaryBright.withValues(alpha: 0.56),
                  )
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.magenta : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInPanel extends StatelessWidget {
  const _SignInPanel({
    required this.email,
    required this.password,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onSelectDemoAccount,
    super.key,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;
  final VoidCallback onForgotPassword;
  final ValueChanged<DemoAccount> onSelectDemoAccount;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('welcome-email'),
            controller: email,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            decoration: InputDecoration(
              labelText: context.tr('Email address'),
              hintText: 'name@email.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 13),
          TextField(
            key: const Key('welcome-password'),
            controller: password,
            enabled: !isLoading,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: context.tr('Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: context.tr(
                  obscurePassword ? 'Show password' : 'Hide password',
                ),
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: Text(context.tr('Forgot password?')),
            ),
          ),
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 19,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          GradientButton(
            label: isLoading
                ? context.tr('Signing in...')
                : context.tr('Enter PULLUP'),
            icon: Icons.arrow_forward_rounded,
            onPressed: isLoading ? null : onSubmit,
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('open-demo-accounts'),
            onPressed: isLoading
                ? null
                : () => _showDemoAccounts(context, onSelectDemoAccount),
            icon: const Icon(Icons.science_outlined),
            label: Text(context.tr('Use a demo account')),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  context.tr('or'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onSubmit,
                  icon: const Icon(Icons.g_mobiledata_rounded),
                  label: const Text('Google'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onSubmit,
                  icon: const Icon(Icons.apple_rounded),
                  label: const Text('Apple'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.magenta,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Create your PULLUP profile'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.tr(
                        'One account lets you join nights and host your own events.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GradientButton(
          label: context.tr('Start registration'),
          icon: Icons.arrow_forward_rounded,
          onPressed: onCreateAccount,
        ),
        const SizedBox(height: 10),
        Text(
          context.tr('PULLUP is reserved for adults aged 18 and over.'),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

Future<void> _showDemoAccounts(
  BuildContext context,
  ValueChanged<DemoAccount> onSelected,
) async {
  final selected = await showModalBottomSheet<DemoAccount>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Demo accounts'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              context.tr(
                'Choose a client, host or professional profile to test every flow.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            for (final account in demoAccounts) ...[
              ListTile(
                key: Key('demo-account-${account.userId}'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.26),
                  child: Text(
                    account.displayName.characters.first,
                    style: TextStyle(
                      color: AppColors.magenta,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(account.displayName)),
                    if (account.isProfessional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.blue.withValues(alpha: 0.42),
                          ),
                        ),
                        child: Text(
                          'PRO · ${account.professionalCategory!.label.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${account.eventLabel}\n${account.email}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => Navigator.of(context).pop(account),
              ),
              const SizedBox(height: 9),
            ],
          ],
        ),
      ),
    ),
  );
  if (selected != null) onSelected(selected);
}

class _Entrance extends StatefulWidget {
  const _Entrance({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _visible ? 1 : 0),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      child: widget.child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
