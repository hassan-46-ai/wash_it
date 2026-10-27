import 'package:flutter/material.dart';
import '../core/glass.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'captain/captain_shell.dart';
import 'customer/customer_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool signup = false;
  Role role = Role.customer;
  final email = TextEditingController(), pass = TextEditingController();

  void _submit() {
    final a = AppScope.of(context);
    if (email.text.trim().isEmpty || pass.text.length < 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid email and a password (4+ chars)')));
      return;
    }
    if (role == Role.captain) {
      a.signInCaptain();
      goTo(context, const CaptainShell());
    } else if (signup) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else {
      a.signInCustomer();
      goTo(context, const CustomerShell());
    }
  }

  Widget _roleChip(Role r, String label, IconData icon) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => role = r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: role == r ? Colors.white.withOpacity(.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => GlassScaffold(
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Image.asset(Img.mascot, height: 130),
          const SizedBox(height: 8),
          Center(
              child: Text(signup ? 'Create account' : 'Welcome back',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(children: [
              Row(children: [
                _roleChip(Role.customer, 'Customer', Icons.person),
                _roleChip(Role.captain, 'Captain', Icons.badge),
              ]),
              const SizedBox(height: 16),
              GlassField('Email', Icons.email_outlined, controller: email, type: TextInputType.emailAddress),
              GlassField('Password', Icons.lock_outline, controller: pass, obscure: true),
              const SizedBox(height: 4),
              PrimaryButton(signup && role == Role.customer ? 'Continue' : 'Login', onTap: _submit),
              if (role == Role.customer)
                TextButton(
                    onPressed: () => setState(() => signup = !signup),
                    child: Text(signup ? 'I already have an account' : "New here? Sign up",
                        style: const TextStyle(color: Colors.white))),
            ]),
          ),
        ]),
      );
}

/// Step 1: name + phone. Step 2: car, address, how did you hear about us.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final name = TextEditingController(), phone = TextEditingController();
  final car = TextEditingController(), address = TextEditingController();
  String? source;
  static const sources = ['Instagram / Facebook', 'A friend', 'Google', 'Passing by'];

  void _next() {
    final ok = step == 0
        ? name.text.trim().isNotEmpty && phone.text.trim().length >= 8
        : car.text.trim().isNotEmpty && address.text.trim().isNotEmpty && source != null;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields')));
      return;
    }
    if (step == 0) return setState(() => step = 1);
    AppScope.of(context).signInCustomer(
        p: Profile(name: name.text.trim(), phone: phone.text.trim(), car: car.text.trim(), address: address.text.trim(), source: source!));
    goTo(context, const CustomerShell());
  }

  @override
  Widget build(BuildContext context) => GlassScaffold(
        title: 'Step ${step + 1} of 2',
        body: ListView(padding: const EdgeInsets.all(20), children: [
          LinearProgressIndicator(value: (step + 1) / 2, minHeight: 6, backgroundColor: Colors.white24, color: Colors.white),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: GlassCard(
              key: ValueKey(step),
              child: step == 0
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tell us about you', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      GlassField('Full name', Icons.person_outline, controller: name),
                      GlassField('Phone number', Icons.phone_outlined, controller: phone, type: TextInputType.phone),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('A few quick questions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      GlassField('Car model (e.g. Kia Cerato 2021)', Icons.directions_car_outlined, controller: car),
                      GlassField('Your address', Icons.location_on_outlined, controller: address, lines: 2),
                      const Text('How did you hear about us?'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in sources)
                          ChoiceChip(label: Text(s), selected: source == s, onSelected: (_) => setState(() => source = s)),
                      ]),
                    ]),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(step == 0 ? 'Next' : 'Finish', onTap: _next),
        ]),
      );
}
