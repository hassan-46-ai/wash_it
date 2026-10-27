import 'package:flutter/material.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../auth.dart';
import 'booking_screen.dart';
import 'orders_tab.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => GlassScaffold(
        body: IndexedStack(index: tab, children: const [HomeTab(), OrdersTab(), ProfileTab()]),
        bottom: GlassNav(index: tab, onChanged: (i) => setState(() => tab = i), items: const [
          (Icons.home_rounded, 'Home'),
          (Icons.receipt_long_rounded, 'Orders'),
          (Icons.person_rounded, 'Profile'),
        ]),
      );
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  Widget _title(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 0, 10),
      child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)));

  Widget _stat(String v, String l) => Expanded(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [
            Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Hello 👋', style: TextStyle(color: Colors.white70)),
            Text(a.profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ]),
        ),
        Image.asset(Img.mascot, height: 56),
      ]),
      const SizedBox(height: 16),
      GlassCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(Img.wide, height: 170, width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Text('Sparkling clean, right at your door',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              PrimaryButton('Book a wash', icon: Icons.local_car_wash,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()))),
            ]),
          ),
        ]),
      ),
      Row(children: [
        _stat('⭐ ${a.avgReview.toStringAsFixed(1)}', 'Average rating'),
        const SizedBox(width: 10),
        _stat('${a.reviews.length}+', 'Happy clients'),
        const SizedBox(width: 10),
        _stat('${a.employees.length}', 'Top captains'),
      ]),
      _title('What our clients say'),
      SizedBox(
        height: 250,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final r in a.reviews)
            SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.asset(r.image, height: 110, width: double.infinity, fit: BoxFit.cover)),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Stars(r.stars.toDouble()),
                        const SizedBox(height: 6),
                        Text(r.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text('— ${r.author}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ),
      _title('Fresh results'),
      SizedBox(
        height: 130,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final i in [Img.bay, Img.tall, Img.car, Img.wide])
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                      color: Colors.white.withOpacity(.15),
                      child: Image.asset(i, width: 180, height: 130, fit: BoxFit.cover))),
            ),
        ]),
      ),
    ]);
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  Widget _row(IconData i, String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(i, color: kAccent), const SizedBox(width: 12), Expanded(child: Text(t))]));

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).profile;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 110), children: [
      Center(child: Avatar(p.name, r: 44)),
      const SizedBox(height: 10),
      Center(child: Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
      const SizedBox(height: 20),
      GlassCard(
        child: Column(children: [
          _row(Icons.phone, p.phone),
          _row(Icons.directions_car, p.car),
          _row(Icons.location_on, p.address),
          if (p.source.isNotEmpty) _row(Icons.campaign, 'Found us via ${p.source}'),
        ]),
      ),
      PrimaryButton('Log out', icon: Icons.logout, onTap: () {
        AppScope.of(context).signOut();
        goTo(context, const AuthScreen());
      }),
    ]);
  }
}
