import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class JobScreen extends StatelessWidget {
  final Order order;
  const JobScreen(this.order, {super.key});

  Future<void> _pick(BuildContext c, {required bool before}) async {
    final a = AppScope.of(c);
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (x != null) a.addPhoto(order, x.path, before: before);
  }

  Widget _photos(BuildContext c, String title, List<String> l, bool before, bool canAdd) => GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            if (canAdd)
              TextButton.icon(
                  onPressed: () => _pick(c, before: before),
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Add')),
          ]),
          SizedBox(
            height: 90,
            child: l.isEmpty
                ? const Align(alignment: Alignment.centerLeft, child: Text('No photos yet', style: TextStyle(color: Colors.white60)))
                : ListView(scrollDirection: Axis.horizontal, children: [
                    for (final p in l)
                      Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(File(p), width: 90, height: 90, fit: BoxFit.cover))),
                  ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final o = order;
    final working = o.status == Status.working;
    final ready = o.before.isNotEmpty && o.after.isNotEmpty;
    return GlassScaffold(
      title: 'Order #${o.id}',
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(o.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              StatusChip(o.status),
            ]),
            const SizedBox(height: 8),
            Text('${o.car}  •  ${o.servicesText}'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => openMap(o.address), icon: const Icon(Icons.map), label: const Text('Navigate'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => callPhone(o.phone), icon: const Icon(Icons.call), label: const Text('Call'))),
            ]),
          ]),
        ),
        if (o.status == Status.accepted)
          PrimaryButton('I have arrived – start washing', icon: Icons.flag, onTap: () => a.start(o)),
        if (working || o.status == Status.completed) ...[
          _photos(context, 'Before cleaning', o.before, true, working),
          _photos(context, 'After cleaning', o.after, false, working),
        ],
        if (working) ...[
          GlassCard(
            child: Row(children: [
              const Icon(Icons.payments, color: kAccent),
              const SizedBox(width: 12),
              const Expanded(child: Text('Amount to collect')),
              Text('EGP ${o.total.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ]),
          ),
          PrimaryButton('Submit payment & finish', icon: Icons.check_circle, onTap: ready
              ? () {
                  a.completeWithPayment(o);
                  Navigator.pop(context);
                }
              : null),
          if (!ready)
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Add at least one before and one after photo', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
        ],
        if (o.status == Status.completed)
          const GlassCard(child: Row(children: [Icon(Icons.verified, color: Color(0xFF3DDC97)), SizedBox(width: 10), Text('Paid & completed')])),
      ]),
    );
  }
}
