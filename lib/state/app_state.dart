import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../models/models.dart';

/// Single source of truth (in-memory). Swap the methods for Firebase/REST calls.
class AppState extends ChangeNotifier {
  Role? role;
  Profile profile = Profile();
  int _id = 100;

  final employees = [
    Employee('e1', 'Ahmed Hassan', '+201001234567', 4.9, 128, 342),
    Employee('e2', 'Omar Khaled', '+201112223344', 4.7, 86, 210),
    Employee('e3', 'Youssef Adel', '+201223334455', 4.8, 102, 260),
    Employee('e4', 'Mostafa Samir', '+201556667788', 4.5, 41, 95),
  ];
  late Employee me = employees.first; // signed-in captain (demo)

  final reviews = <Review>[
    const Review('Karim S.', 'My car looks brand new, and he arrived exactly on time!', 5, Img.bay),
    const Review('Nour A.', 'Interior cleaning was spotless. Very polite captain.', 5, Img.car),
    const Review('Hossam M.', 'Great value, the engine clean was impressive.', 4, Img.tall),
  ];

  late final orders = <Order>[
    for (var i = 0; i < 3; i++)
      Order(i + 1, ['Sara Mahmoud', 'Ali Fathy', 'Mona Ezz'][i], '+2010000000$i', 'Alexandria',
              ['Kia Cerato', 'Hyundai Elantra', 'BMW 320i'][i], [allServices[0], allServices[1]],
              DateTime.now().subtract(Duration(days: i + 1)), employees.first)
          ..status = Status.completed
          ..paid = true
          ..rating = 5 - (i == 2 ? 1 : 0),
  ];

  // ---- derived ----
  double get avgReview => reviews.fold(0, (s, r) => s + r.stars) / reviews.length;
  List<Order> get customerOrders => orders.where((o) => o.mine).toList().reversed.toList();
  List<Order> get captainOrders => orders.where((o) => o.employee.id == me.id).toList().reversed.toList();
  double get earnings => captainOrders.where((o) => o.paid).fold(0, (s, o) => s + o.total);

  List<Employee> availableAt(DateTime w) => employees
      .where((e) => !orders.any((o) => o.employee.id == e.id && o.status != Status.completed && o.when == w))
      .toList()
    ..sort((a, b) => b.rating.compareTo(a.rating));

  // ---- auth ----
  void signInCustomer({Profile? p}) {
    role = Role.customer;
    profile = p ?? Profile(name: 'Mohamed', phone: '+201000000000', car: 'Toyota Corolla 2020', address: 'Smouha, Alexandria');
    notifyListeners();
  }

  void signInCaptain() {
    role = Role.captain;
    notifyListeners();
  }

  void signOut() {
    role = null;
    notifyListeners();
  }

  // ---- customer actions ----
  void book(List<Service> s, DateTime when, Employee e, String address) {
    orders.add(Order(_id++, profile.name, profile.phone, address, profile.car, s, when, e, mine: true));
    notifyListeners();
  }

  void rate(Order o, int stars, String comment) {
    o.rating = stars;
    final e = o.employee;
    e.rating = (e.rating * e.ratingCount + stars) / (e.ratingCount + 1);
    e.ratingCount++;
    if (comment.trim().isNotEmpty) reviews.insert(0, Review(profile.name, comment.trim(), stars, Img.bay));
    notifyListeners();
  }

  // ---- captain actions ----
  void accept(Order o) => _set(o, Status.accepted);
  void start(Order o) => _set(o, Status.working);

  void addPhoto(Order o, String path, {required bool before}) {
    (before ? o.before : o.after).add(path);
    notifyListeners();
  }

  void completeWithPayment(Order o) {
    o.paid = true;
    o.employee.washed++;
    _set(o, Status.completed);
  }

  /// Demo helper: pretends a customer just booked this captain.
  void simulateIncoming() {
    orders.add(Order(_id++, 'Sara Mahmoud', '+201099887766', 'Stanley, Alexandria', 'Mazda 3',
        [allServices[0], allServices[2]], DateTime.now().add(const Duration(hours: 2)), me));
    notifyListeners();
  }

  void _set(Order o, Status s) {
    o.status = s;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
