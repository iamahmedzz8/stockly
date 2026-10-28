import 'package:flutter/material.dart';

const stocklyOrange = Color(0xFFFF5A1F);

class StocklyLogo extends StatelessWidget {
  final double size;

  const StocklyLogo({super.key, this.size = 76});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: stocklyOrange,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Colors.white,
        size: size * 0.53,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const StocklyLogo(size: 100),
            const SizedBox(height: 22),
            const Text(
              'Stockly',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Smart Product & Inventory Management',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: stocklyOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
