import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const kPrimary = Color(0xFF3B6CF6);
const kBg = Color(0xFFF5F7FB);

// ---------- Model & in-memory store (replace with Firebase/REST) ----------
enum Status { pending, accepted, inProgress, completed }

class Order {
  final int id;
  final String service, address;
  final double price;
  final DateTime when;
  Status status = Status.pending;
  final List<String> before = [], after = [];
  bool feePaid = false;
  Order(this.id, this.service, this.price, this.when, this.address);
}

class Store {
  static final orders = ValueNotifier<List<Order>>([]);
  static int _n = 1;
  static void add(String s, double p, DateTime w, String a) =>
      orders.value = [...orders.value, Order(_n++, s, p, w, a)];
  static void refresh() => orders.value = [...orders.value];
}

const services = [
  ('Exterior Wash', 15.0, Icons.local_car_wash),
  ('Interior Cleaning', 25.0, Icons.airline_seat_recline_normal),
  ('Full Detailing', 60.0, Icons.auto_awesome),
  ('Engine Wash', 20.0, Icons.settings),
];

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'WashGo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
      scaffoldBackgroundColor: kBg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: kBg, elevation: 0, centerTitle: true),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    home: const RoleScreen(),
  );
}

Widget card({required Widget child, VoidCallback? onTap}) => Card(
  elevation: 0,
  color: Colors.white,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(16), child: child)),
);

Color statusColor(Status s) => switch (s) {
Status.pending => Colors.orange,
Status.accepted => Colors.blue,
Status.inProgress => Colors.purple,
Status.completed => Colors.green,
};

Widget chip(Status s) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
      color: statusColor(s).withOpacity(.12), borderRadius: BorderRadius.circular(20)),
  child: Text(s.name, style: TextStyle(color: statusColor(s), fontWeight: FontWeight.w600)),
);

// ---------- Role selection ----------
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.local_car_wash, size: 90, color: kPrimary),
          const SizedBox(height: 12),
          const Text('WashGo',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('Car wash at your doorstep'),
          const SizedBox(height: 48),
          FilledButton(
              onPressed: () => Navigator.push(
                  c, MaterialPageRoute(builder: (_) => const CustomerHome())),
              child: const Text('Continue as Customer')),
          const SizedBox(height: 12),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () => Navigator.push(
                  c, MaterialPageRoute(builder: (_) => const EmployeeHome())),
              child: const Text('Continue as Employee')),
        ]),
      ),
    ),
  );
}

// ---------- Customer ----------
class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int tab = 0;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(tab == 0 ? 'Our Services' : 'My Bookings')),
    body: tab == 0 ? _services() : _bookings(),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bookings'),
      ],
    ),
  );

  Widget _services() => ListView(padding: const EdgeInsets.all(16), children: [
    for (final s in services)
      card(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => BookScreen(s.$1, s.$2))),
        child: Row(children: [
          CircleAvatar(
              radius: 26,
              backgroundColor: kPrimary.withOpacity(.1),
              child: Icon(s.$3, color: kPrimary)),
          const SizedBox(width: 14),
          Expanded(
              child: Text(s.$1,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Text('\$${s.$2.toStringAsFixed(0)}',
              style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
        ]),
      ),
  ]);

  Widget _bookings() => ValueListenableBuilder<List<Order>>(
    valueListenable: Store.orders,
    builder: (_, list, __) => list.isEmpty
        ? const Center(child: Text('No bookings yet'))
        : ListView(padding: const EdgeInsets.all(16), children: [
      for (final o in list.reversed)
        card(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => OrderDetail(o, employee: false))),
          child: Row(children: [
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.service,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${_fmt(o.when)}\n${o.address}',
                      style: const TextStyle(color: Colors.black54)),
                ])),
            chip(o.status),
          ]),
        ),
    ]),
  );
}

String _fmt(DateTime d) =>
    '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class BookScreen extends StatefulWidget {
  final String service;
  final double price;
  const BookScreen(this.service, this.price, {super.key});
  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  DateTime? date;
  TimeOfDay? time;
  final addr = TextEditingController();

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: Text(widget.service)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      card(
        onTap: () async {
          final d = await showDatePicker(
              context: c,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)));
          if (d != null) setState(() => date = d);
        },
        child: Row(children: [
          const Icon(Icons.calendar_today, color: kPrimary),
          const SizedBox(width: 12),
          Text(date == null ? 'Select date' : '${date!.day}/${date!.month}/${date!.year}'),
        ]),
      ),
      card(
        onTap: () async {
          final t = await showTimePicker(context: c, initialTime: TimeOfDay.now());
          if (t != null) setState(() => time = t);
        },
        child: Row(children: [
          const Icon(Icons.access_time, color: kPrimary),
          const SizedBox(width: 12),
          Text(time == null ? 'Select time' : time!.format(c)),
        ]),
      ),
      TextField(
        controller: addr,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Location / address (or paste a map link)',
          prefixIcon: const Icon(Icons.location_on, color: kPrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () {
          if (date == null || time == null || addr.text.trim().isEmpty) {
            ScaffoldMessenger.of(c).showSnackBar(
                const SnackBar(content: Text('Please fill date, time and location')));
            return;
          }
          Store.add(
              widget.service,
              widget.price,
              DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute),
              addr.text.trim());
          Navigator.pop(c);
          ScaffoldMessenger.of(c)
              .showSnackBar(const SnackBar(content: Text('Booking sent!')));
        },
        child: Text('Book now  •  \$${widget.price.toStringAsFixed(0)}'),
      ),
    ]),
  );
}

// ---------- Employee ----------
class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});
  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  int _seen = 0;

  // In-app "notification" when a new order arrives.
  // For real push, integrate Firebase Cloud Messaging.
  void _onChange() {
    final n = Store.orders.value.length;
    if (n > _seen && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: kPrimary,
          content: Text('🔔 New order: ${Store.orders.value.last.service}')));
    }
    _seen = n;
  }

  @override
  void initState() {
    super.initState();
    _seen = Store.orders.value.length;
    Store.orders.addListener(_onChange);
  }

  @override
  void dispose() {
    Store.orders.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Orders')),
    body: ValueListenableBuilder<List<Order>>(
      valueListenable: Store.orders,
      builder: (_, list, __) => list.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView(padding: const EdgeInsets.all(16), children: [
        for (final o in list.reversed)
          card(
            onTap: () => Navigator.push(
                c, MaterialPageRoute(builder: (_) => OrderDetail(o, employee: true))),
            child: Row(children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('#${o.id} ${o.service}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${_fmt(o.when)}\n📍 ${o.address}',
                        style: const TextStyle(color: Colors.black54)),
                  ])),
              chip(o.status),
            ]),
          ),
      ]),
    ),
  );
}

class OrderDetail extends StatefulWidget {
  final Order o;
  final bool employee;
  const OrderDetail(this.o, {required this.employee, super.key});
  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final picker = ImagePicker();
  Order get o => widget.o;

  Future<void> _pick(List<String> target) async {
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (x != null) setState(() => target.add(x.path));
  }

  Widget _photos(String title, List<String> list) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          if (widget.employee && o.status != Status.completed && o.status != Status.pending)
            TextButton.icon(
                onPressed: () => _pick(list),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add')),
        ]),
        SizedBox(
          height: 90,
          child: list.isEmpty
              ? const Align(alignment: Alignment.centerLeft, child: Text('No photos'))
              : ListView(scrollDirection: Axis.horizontal, children: [
            for (final p in list)
              Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(p), width: 90, height: 90, fit: BoxFit.cover))),
          ]),
        ),
        const SizedBox(height: 12),
      ]);

  @override
  Widget build(BuildContext c) {
    final e = widget.employee;
    return Scaffold(
      appBar: AppBar(title: Text('Order #${o.id}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(o.service,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                chip(o.status)
              ]),
              const SizedBox(height: 8),
              Text('🕒 ${_fmt(o.when)}'),
              Text('📍 ${o.address}'),
              Text('💵 \$${o.price.toStringAsFixed(0)}  •  ${o.feePaid ? "Fees collected" : "Fees not collected"}'),
            ])),
        card(
            child: Column(children: [
              _photos('Before cleaning', o.before),
              _photos('After cleaning', o.after),
            ])),
        if (e) ..._actions(c),
      ]),
    );
  }

  List<Widget> _actions(BuildContext c) {
    void go(Status s) {
      setState(() => o.status = s);
      Store.refresh();
    }

    switch (o.status) {
      case Status.pending:
        return [FilledButton(onPressed: () => go(Status.accepted), child: const Text('Accept order'))];
      case Status.accepted:
        return [
          FilledButton(
              onPressed: o.before.isEmpty
                  ? null
                  : () => go(Status.inProgress),
              child: Text(o.before.isEmpty ? 'Add a "before" photo to start' : 'Start cleaning'))
        ];
      case Status.inProgress:
        return [
          CheckboxListTile(
              value: o.feePaid,
              title: const Text('Fees collected'),
              onChanged: (v) => setState(() => o.feePaid = v ?? false)),
          const SizedBox(height: 8),
          FilledButton(
              onPressed: (o.after.isEmpty || !o.feePaid)
                  ? null
                  : () {
                go(Status.completed);
                Navigator.pop(c);
              },
              child: const Text('Submit & complete')),
          if (o.after.isEmpty || !o.feePaid)
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Requires an "after" photo and fees collected',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
        ];
      case Status.completed:
        return [];
    }
  }
}