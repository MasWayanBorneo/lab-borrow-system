import 'package:flutter/material.dart';

class LoanStatusBadge extends StatelessWidget {
  const LoanStatusBadge({super.key, required this.status});

  final String status;

  static const Map<String, Color> _colors = {
    'pending': Colors.amber,
    'approved': Colors.green,
    'rejected': Colors.red,
    'returned': Colors.grey,
  };

  static const Map<String, String> _labels = {
    'pending': 'Menunggu',
    'approved': 'Disetujui',
    'rejected': 'Ditolak',
    'returned': 'Dikembalikan',
  };

  @override
  Widget build(BuildContext context) {
    Color color = _colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labels[status] ?? status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
