import 'package:flutter/material.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../auth.dart';
import 'job_screen.dart';

class CaptainShell extends StatefulWidget {
  const CaptainShell({super.key});
  @override
  State<CaptainShell> createState() => _CaptainShellState();
}

class _CaptainShellState extends State<CaptainShell> {
  int tab = 0;
  int _lastPending = 0;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    // In-app alert when a new request arrives (use FCM for real push).
    final pending = a.captainOrders.where((o) => o.status == Status.pending).length;
    if (pending > _lastPending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('🔔 New wash request! Open Slots to accept.')));
        }
      });
    }
    _lastPending = pending;

    return GlassScaffold(
      body: IndexedStack(index: tab, children: const [DashboardTab(), SlotsTab(), CaptainProfileTab()]),
      bottom: GlassNav(index: tab, onChanged: (i) => setState(() => tab = i), items: const [
        (Icons.dashboard_rounded, 'Dashboard'),
        (Icons.event_available_rounded, 'Slots'),
        (Icons.person_rounded, 'Profile'),
      ]),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Widget _stat(String v, String l) => Expanded(
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final me = a.me;
    final done = a.captainOrders.where((o) => o.status == Status.completed).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), children: [
      GlassCard(
        child: Column(children: [
          Row(children: [
            Avatar(me.name, r: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(me.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Row(children: [Stars(me.rating), Text('  ${me.rating.toStringAsFixed(1)}')]),
              ]),
            ),
          ]),
          const Divider(height: 28, color: Colors.white24),
          Row(children: [
            _stat('${me.washed}', 'Cars washed'),
            _stat('${me.ratingCount}', 'Reviews'),
            _stat('EGP ${a.earnings.toInt()}', 'Earned'),
          ]),
        ]),
      ),
      const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 0, 10),
          child: Text('Washed cars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
      if (done.isEmpty) const Text('Nothing yet.'),
      for (final o in done)
        GlassCard(
          child: Row(children: [
            const Icon(Icons.directions_car, color: kAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.car, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${o.customerName} • ${fmtWhen(o.when)}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ]),
            ),
            if (o.rating != null) Column(children: [Stars(o.rating!.toDouble(), size: 13), Text('EGP ${o.total.toInt()}', style: const TextStyle(fontSize: 12))]),
          ]),
        ),
    ]);
  }
}

class SlotsTab extends StatelessWidget {
  const SlotsTab({super.key});

  Widget _action(IconData i, String t, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [Icon(i, size: 18, color: kAccent), const SizedBox(width: 8), Expanded(child: Text(t))]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final list = a.captainOrders.where((o) => o.status != Status.completed).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 110), children: [
      Row(children: [
        const Expanded(child: Text('My slots', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
        TextButton.icon(
            onPressed: a.simulateIncoming,
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Simulate request')),
      ]),
      if (list.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('No upcoming slots'))),
      for (final o in list)
        GlassCard(
          onTap: o.status == Status.pending
              ? null
              : () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(o))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('${o.customerName} • ${o.car}', style: const TextStyle(fontWeight: FontWeight.w800))),
              StatusChip(o.status),
            ]),
            const SizedBox(height: 6),
            Text(o.servicesText, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            _action(Icons.schedule, fmtWhen(o.when), () {}),
            _action(Icons.location_on, o.address, () => openMap(o.address)),
            _action(Icons.phone, o.phone, () => callPhone(o.phone)),
            const SizedBox(height: 8),
            if (o.status == Status.pending) PrimaryButton('Accept order  •  EGP ${o.total.toInt()}', onTap: () => a.accept(o)),
            if (o.status != Status.pending) const Text('Tap to open job →', style: TextStyle(color: Colors.white70)),
          ]),
        ),
    ]);
  }
}

class CaptainProfileTab extends StatelessWidget {
  const CaptainProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final me = AppScope.of(context).me;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 32, 16, 110), children: [
      Center(child: Avatar(me.name, r: 44)),
      const SizedBox(height: 10),
      Center(child: Text(me.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
      Center(child: Text(me.phone, style: const TextStyle(color: Colors.white70))),
      const SizedBox(height: 24),
      PrimaryButton('Log out', icon: Icons.logout, onTap: () {
        AppScope.of(context).signOut();
        goTo(context, const AuthScreen());
      }),
    ]);
  }
}
