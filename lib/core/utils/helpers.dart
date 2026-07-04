import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Helpers {
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log10(bytes) / log10(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String timeAgo(DateTime date) {
    return timeago.format(date);
  }

  static double log10(num x) => log(x) / ln10;
  static double ln10 = 2.302585092994046;
  static double pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Games': Colors.purple,
      'Productivity': Colors.blue,
      'Social': Colors.pink,
      'Entertainment': Colors.red,
      'Education': Colors.teal,
      'Finance': Colors.green,
      'Health & Fitness': Colors.orange,
      'Music & Audio': Colors.indigo,
      'Photography': Colors.cyan,
      'Shopping': Colors.amber,
      'Tools': Colors.grey,
      'Travel': Colors.lightBlue,
      'Communication': Colors.deepPurple,
      'News & Magazines': Colors.brown,
    };
    return colors[category] ?? Colors.blueGrey;
  }
}

// Extension for cleaner null handling
extension StringExtension on String? {
  String get orEmpty => this ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension IntExtension on int? {
  int get orZero => this ?? 0;
}

extension DoubleExtension on double? {
  double get orZero => this ?? 0.0;
}
