import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'theme.dart';
import 'utils.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  Widget _blob(double s, Color c) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kDeep, kPrimary, Color(0xFF2AA3FF)]),
        ),
        child: Stack(children: [
          Positioned(top: -90, right: -70, child: _blob(280, kAccent.withOpacity(.45))),
          Positioned(bottom: 100, left: -100, child: _blob(300, Colors.white.withOpacity(.18))),
          child,
        ]),
      );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius, opacity;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 24,
    this.opacity = .14,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Material(
              color: Colors.white.withOpacity(opacity),
              child: InkWell(
                onTap: onTap,
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(.28)),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
}

class GlassScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  const GlassScaffold({super.key, this.title, required this.body, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) => GlassBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          appBar: title == null
              ? null
              : AppBar(
                  title: Text(title!, style: const TextStyle(fontWeight: FontWeight.w700)),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: actions),
          body: SafeArea(top: title == null, child: body),
          bottomNavigationBar: bottom,
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const PrimaryButton(this.label, {super.key, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? .45 : 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.white, Color(0xFFD6EEFF)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: kPrimary), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      );
}

class GlassField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? type;
  final int lines;
  const GlassField(this.hint, this.icon,
      {super.key, this.controller, this.obscure = false, this.type, this.lines = 1});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(double a) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(a)));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(.12),
          border: b(.28),
          enabledBorder: b(.28),
          focusedBorder: b(.9),
        ),
      ),
    );
  }
}

class Stars extends StatelessWidget {
  final double value, size;
  const Stars(this.value, {super.key, this.size = 16});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            5,
            (i) => Icon(
                value >= i + 1
                    ? Icons.star_rounded
                    : value >= i + .5
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                size: size,
                color: kGold)),
      );
}

class StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const StarPicker(this.value, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            5,
            (i) => GestureDetector(
                  onTap: () => onChanged(i + 1),
                  child: AnimatedScale(
                    scale: value > i ? 1.15 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(value > i ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 46, color: kGold),
                  ),
                )),
      );
}

class StatusChip extends StatelessWidget {
  final Status status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: statusColor(status).withOpacity(.2),
            border: Border.all(color: statusColor(status)),
            borderRadius: BorderRadius.circular(20)),
        child: Text(statusLabel(status),
            style: TextStyle(color: statusColor(status), fontSize: 12, fontWeight: FontWeight.w700)),
      );
}

class Avatar extends StatelessWidget {
  final String name;
  final double r;
  const Avatar(this.name, {super.key, this.r = 24});
  @override
  Widget build(BuildContext context) => CircleAvatar(
      radius: r,
      backgroundColor: Colors.white.withOpacity(.25),
      child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
          style: TextStyle(fontSize: r * .9, fontWeight: FontWeight.w800)));
}

class GlassNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<(IconData, String)> items;
  const GlassNav({super.key, required this.index, required this.onChanged, required this.items});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    border: Border.all(color: Colors.white.withOpacity(.3)),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: i == index ? Colors.white.withOpacity(.28) : Colors.transparent,
                              borderRadius: BorderRadius.circular(22)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(items[i].$1, size: 22),
                            Text(items[i].$2, style: const TextStyle(fontSize: 11)),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      );
}
