import 'package:flutter/material.dart';


class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key});


  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(width: 88, height: 64, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 180, color: Colors.black12),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: Colors.black12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}