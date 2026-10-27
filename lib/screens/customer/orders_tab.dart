import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/glass.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  Widget _photos(String label, List<String> l) => l.isEmpty
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 4),
            SizedBox(
              height: 64,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final p in l)
                  Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(p), width: 64, height: 64, fit: BoxFit.cover))),
              ]),
            ),
          ]),
        );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    final list = a.customerOrders;
    if (list.isEmpty) {
      return const Center(child: Text('No orders yet.\nBook your first wash!', textAlign: TextAlign.center));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), children: [
      for (final o in list)
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(o.servicesText, style: const TextStyle(fontWeight: FontWeight.w800))),
              Text('EGP ${o.total.toInt()}'),
            ]),
            const SizedBox(height: 6),
            Text(fmtWhen(o.when), style: const TextStyle(color: Colors.white70)),
            Text('Captain: ${o.employee.name}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Row(children: [
              StatusChip(o.status),
              const Spacer(),
              if (o.status != Status.completed)
                IconButton(onPressed: () => callPhone(o.employee.phone), icon: const Icon(Icons.call)),
            ]),
            _photos('Before', o.before),
            _photos('After', o.after),
            if (o.status == Status.completed) ...[
              const SizedBox(height: 10),
              o.rating == null
                  ? PrimaryButton('Rate ${o.employee.name}', icon: Icons.star_rounded, onTap: () => _rate(context, o))
                  : Row(children: [const Text('Your rating  '), Stars(o.rating!.toDouble())]),
            ],
          ]),
        ),
    ]);
  }

  void _rate(BuildContext context, Order o) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateSheet(o));
}

class RateSheet extends StatefulWidget {
  final Order order;
  const RateSheet(this.order, {super.key});
  @override
  State<RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<RateSheet> {
  int stars = 5;
  final text = TextEditingController();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).viewInsets.bottom + 12),
        child: GlassCard(
          opacity: .35,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Avatar(widget.order.employee.name, r: 32),
            const SizedBox(height: 8),
            Text('How was ${widget.order.employee.name}?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            StarPicker(stars, (v) => setState(() => stars = v)),
            const SizedBox(height: 16),
            GlassField('Leave a comment (optional)', Icons.chat_bubble_outline, controller: text),
            PrimaryButton('Submit', onTap: () {
              AppScope.of(context).rate(widget.order, stars, text.text);
              Navigator.pop(context);
            }),
          ]),
        ),
      );
}
