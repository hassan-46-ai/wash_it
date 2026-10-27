import 'package:flutter/material.dart';

enum Role { customer, captain }

enum Status { pending, accepted, working, completed }

class Service {
  final String id, name;
  final double price;
  final IconData icon;
  const Service(this.id, this.name, this.price, this.icon);
}

const allServices = [
  Service('ext', 'Exterior Wash', 150, Icons.local_car_wash),
  Service('int', 'Interior Cleaning', 200, Icons.airline_seat_recline_extra),
  Service('eng', 'Engine Clean', 180, Icons.settings),
  Service('det', 'Full Detailing', 500, Icons.auto_awesome),
  Service('tire', 'Tire Shine', 80, Icons.tire_repair),
];

class Profile {
  String name, phone, car, address, source;
  Profile({this.name = '', this.phone = '', this.car = '', this.address = '', this.source = ''});
}

class Employee {
  final String id, name, phone;
  double rating;
  int ratingCount, washed;
  Employee(this.id, this.name, this.phone, this.rating, this.ratingCount, this.washed);
}

class Review {
  final String author, text, image;
  final int stars;
  const Review(this.author, this.text, this.stars, this.image);
}

class Order {
  final int id;
  final String customerName, phone, address, car;
  final List<Service> services;
  final DateTime when;
  final Employee employee;
  final bool mine; // placed by the signed-in customer
  Status status = Status.pending;
  final List<String> before = [], after = [];
  bool paid = false;
  int? rating;
  Order(this.id, this.customerName, this.phone, this.address, this.car, this.services, this.when,
      this.employee, {this.mine = false});
  double get total => services.fold(0, (s, e) => s + e.price);
  String get servicesText => services.map((e) => e.name).join(' + ');
}
