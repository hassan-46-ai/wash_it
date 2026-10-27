import 'package:flutter/material.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final picked = <Service>{};
  DateTime? date;
  TimeOfDay? time;
  Employee? captain;
  TextEditingController? address;

  DateTime? get when =>
      date == null || time == null ? null : DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
  double get total => picked.fold(0, (s, e) => s + e.price);

  Widget _section(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 0, 10),
      child: Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)));

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 60)));
    if (d != null) setState(() { date = d; captain = null; });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (t != null) setState(() { time = t; captain = null; });
  }

  Widget _pickerTile(IconData i, String t, VoidCallback onTap) => Expanded(
        child: GlassCard(
          onTap: onTap,
          child: Row(children: [Icon(i, color: kAccent), const SizedBox(width: 10), Expanded(child: Text(t))]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context);
    address ??= TextEditingController(text: a.profile.address);
    final w = when;
    return GlassScaffold(
      title: 'Book a wash',
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        _section('1. What does your car need?'),
        for (final s in allServices)
          GlassCard(
            opacity: picked.contains(s) ? .3 : .14,
            onTap: () => setState(() => picked.contains(s) ? picked.remove(s) : picked.add(s)),
            child: Row(children: [
              Icon(s.icon, color: kAccent),
              const SizedBox(width: 12),
              Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('EGP ${s.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Icon(picked.contains(s) ? Icons.check_circle : Icons.circle_outlined, color: Colors.white),
            ]),
          ),
        _section('2. Date & time'),
        Row(children: [
          _pickerTile(Icons.calendar_month, date == null ? 'Date' : '${date!.day}/${date!.month}/${date!.year}', _pickDate),
          const SizedBox(width: 10),
          _pickerTile(Icons.schedule, time == null ? 'Time' : time!.format(context), _pickTime),
        ]),
        _section('3. Location'),
        GlassField('Where should we come?', Icons.location_on_outlined, controller: address, lines: 2),
        if (w != null) ...[
          _section('4. Choose your captain'),
          for (final e in a.availableAt(w))
            GlassCard(
              opacity: captain == e ? .3 : .14,
              onTap: () => setState(() => captain = e),
              child: Row(children: [
                Avatar(e.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Row(children: [
                      Stars(e.rating, size: 14),
                      Text('  ${e.rating.toStringAsFixed(1)} (${e.ratingCount})',
                          style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ]),
                    Text('${e.washed} cars washed', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ]),
                ),
                Icon(captain == e ? Icons.check_circle : Icons.circle_outlined),
              ]),
            ),
        ],
        const SizedBox(height: 12),
        PrimaryButton('Confirm  •  EGP ${total.toInt()}',
            onTap: picked.isEmpty || captain == null || address!.text.trim().isEmpty
                ? null
                : () {
                    a.book(picked.toList(), w!, captain!, address!.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Request sent to ${captain!.name}')));
                  }),
      ]),
    );
  }
}
