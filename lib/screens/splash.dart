import 'dart:math';
import 'package:flutter/material.dart';
import '../core/glass.dart';
import '../core/utils.dart';
import 'auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
        ..forward().whenComplete(() {
          if (mounted) goTo(context, const AuthScreen());
        });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<Widget> _bubbles(double t, Size s) => List.generate(16, (i) {
        final r = Random(i);
        final size = 10 + r.nextDouble() * 36;
        final y = 1 - ((t * (.6 + r.nextDouble() * .9) + r.nextDouble()) % 1);
        return Positioned(
          left: r.nextDouble() * s.width,
          top: y * s.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.12),
                border: Border.all(color: Colors.white.withOpacity(.5))),
          ),
        );
      });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value;
            final pop = Curves.elasticOut.transform((t * 2).clamp(0.0, 1.0));
            final fade = Curves.easeIn.transform(((t - .35) * 2.2).clamp(0.0, 1.0));
            return Stack(children: [
              ..._bubbles(t, size),
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Transform.translate(
                    offset: Offset(0, sin(t * pi * 8) * 7),
                    child: Transform.scale(scale: pop, child: Image.asset(Img.mascot, width: 210)),
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: fade,
                    child: Transform.translate(
                      offset: Offset(0, (1 - fade) * 20),
                      child: const Column(children: [
                        Text('CARTOON', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 3)),
                        Text('CLEAN CAR',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF45D4FF))),
                        SizedBox(height: 6),
                        Text('Car washing & detailing at your door', style: TextStyle(color: Colors.white70)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                          value: t, minHeight: 6, backgroundColor: Colors.white24, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
