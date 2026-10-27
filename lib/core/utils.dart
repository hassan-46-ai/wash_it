import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

class Img {
  static const mascot = 'assets/images/mascot.png';
  static const wide = 'assets/images/storefront_wide.png';
  static const tall = 'assets/images/storefront_tall.png';
  static const bay = 'assets/images/wash_bay.jpg';
  static const car = 'assets/images/car_cutout.png';
}

String _p(int n) => n.toString().padLeft(2, '0');
String fmtWhen(DateTime d) => '${_p(d.day)}/${_p(d.month)}/${d.year} • ${_p(d.hour)}:${_p(d.minute)}';

Color statusColor(Status s) => switch (s) {
      Status.pending => const Color(0xFFFFB020),
      Status.accepted => const Color(0xFF45D4FF),
      Status.working => const Color(0xFFB388FF),
      Status.completed => const Color(0xFF3DDC97),
    };

String statusLabel(Status s) => switch (s) {
      Status.pending => 'Waiting for captain',
      Status.accepted => 'Captain on the way',
      Status.working => 'Washing now',
      Status.completed => 'Completed',
    };

Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
void callPhone(String phone) => _open('tel:$phone');
void openMap(String address) =>
    _open('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');

/// Replace the whole stack with a fade transition.
void goTo(BuildContext c, Widget page) => Navigator.pushAndRemoveUntil(
      c,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
