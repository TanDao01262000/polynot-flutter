import 'package:intl/intl.dart';

class DateUtils {
  /// Parse a date string from various formats with fallback
  static DateTime parseDate(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    // If it's already a DateTime, return it
    if (dateValue is DateTime) {
      return dateValue;
    }

    String dateString = dateValue.toString().trim();
    
    if (dateString.isEmpty) {
      return DateTime.now();
    }

    // Handle relative time strings first (backend is returning these)
    final relativeTimeResult = _parseRelativeTime(dateString);
    if (relativeTimeResult != null) {
      print('✅ Successfully parsed relative time: $dateString -> $relativeTimeResult');
      return relativeTimeResult;
    }

    // List of common date formats to try
    final List<DateFormat> formats = [
      // ISO 8601 formats
      DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ"),
      DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'"),
      DateFormat("yyyy-MM-ddTHH:mm:ssZ"),
      DateFormat("yyyy-MM-ddTHH:mm:ss'Z'"),
      DateFormat("yyyy-MM-ddTHH:mm:ss"),
      
      // Common backend formats
      DateFormat("yyyy-MM-dd HH:mm:ss"),
      DateFormat("yyyy-MM-dd HH:mm:ss.SSS"),
      DateFormat("MM/dd/yyyy HH:mm:ss"),
      DateFormat("dd/MM/yyyy HH:mm:ss"),
      
      // Date only formats
      DateFormat("yyyy-MM-dd"),
      DateFormat("MM/dd/yyyy"),
      DateFormat("dd/MM/yyyy"),
    ];

    // Try parsing with DateTime.parse first (handles most ISO formats)
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('⚠️ DateTime.parse failed for: $dateString');
    }

    // Try each format
    for (final format in formats) {
      try {
        final parsed = format.parse(dateString);
        print('✅ Successfully parsed date: $dateString -> $parsed using format: ${format.pattern}');
        return parsed;
      } catch (e) {
        // Continue to next format
      }
    }

    // Try Unix timestamp parsing
    try {
      final timestamp = int.tryParse(dateString);
      if (timestamp != null) {
        // Check if it's seconds or milliseconds
        if (timestamp > 1000000000000) {
          // Milliseconds
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          // Seconds
          return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      }
    } catch (e) {
      print('⚠️ Unix timestamp parsing failed for: $dateString');
    }

    // If all else fails, log the error and return current time
    print('❌ Failed to parse date: $dateString, using current time as fallback');
    return DateTime.now();
  }

  /// Parse relative time strings like "18 hours ago", "5 days ago", etc.
  static DateTime? _parseRelativeTime(String dateString) {
    final now = DateTime.now();
    final lowerString = dateString.toLowerCase().trim();
    
    print('🔍 Attempting to parse relative time: "$dateString" -> "$lowerString"');

    try {
      // Handle "just now" or "now"
      if (lowerString.contains('just now') || lowerString == 'now') {
        return now;
      }

      // Handle "X minutes ago"
      final minutesMatch = RegExp(r'(\d+)\s*minutes?\s*ago').firstMatch(lowerString);
      if (minutesMatch != null) {
        final minutes = int.parse(minutesMatch.group(1)!);
        print('✅ Matched minutes pattern: $minutes minutes ago');
        return now.subtract(Duration(minutes: minutes));
      }

      // Handle "X hours ago"
      final hoursMatch = RegExp(r'(\d+)\s*hours?\s*ago').firstMatch(lowerString);
      if (hoursMatch != null) {
        final hours = int.parse(hoursMatch.group(1)!);
        print('✅ Matched hours pattern: $hours hours ago');
        return now.subtract(Duration(hours: hours));
      }

      // Handle "X days ago"
      final daysMatch = RegExp(r'(\d+)\s*days?\s*ago').firstMatch(lowerString);
      if (daysMatch != null) {
        final days = int.parse(daysMatch.group(1)!);
        print('✅ Matched days pattern: $days days ago');
        return now.subtract(Duration(days: days));
      }

      // Handle "X weeks ago"
      final weeksMatch = RegExp(r'(\d+)\s*weeks?\s*ago').firstMatch(lowerString);
      if (weeksMatch != null) {
        final weeks = int.parse(weeksMatch.group(1)!);
        return now.subtract(Duration(days: weeks * 7));
      }

      // Handle "X months ago"
      final monthsMatch = RegExp(r'(\d+)\s*months?\s*ago').firstMatch(lowerString);
      if (monthsMatch != null) {
        final months = int.parse(monthsMatch.group(1)!);
        return DateTime(now.year, now.month - months, now.day, now.hour, now.minute, now.second);
      }

      // Handle "X years ago"
      final yearsMatch = RegExp(r'(\d+)\s*years?\s*ago').firstMatch(lowerString);
      if (yearsMatch != null) {
        final years = int.parse(yearsMatch.group(1)!);
        return DateTime(now.year - years, now.month, now.day, now.hour, now.minute, now.second);
      }

      // Handle "yesterday"
      if (lowerString.contains('yesterday')) {
        return now.subtract(const Duration(days: 1));
      }

      // Handle "last week"
      if (lowerString.contains('last week')) {
        return now.subtract(const Duration(days: 7));
      }

      // Handle "last month"
      if (lowerString.contains('last month')) {
        return DateTime(now.year, now.month - 1, now.day, now.hour, now.minute, now.second);
      }

      // Handle "last year"
      if (lowerString.contains('last year')) {
        return DateTime(now.year - 1, now.month, now.day, now.hour, now.minute, now.second);
      }

    } catch (e) {
      print('⚠️ Error parsing relative time "$dateString": $e');
    }

    print('❌ No relative time pattern matched for: "$dateString"');
    return null;
  }

  /// Format a DateTime to a readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return DateFormat('MMM dd').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Format a DateTime to ISO string for API calls
  static String toIsoString(DateTime date) {
    return date.toIso8601String();
  }

  /// Check if a date string is valid
  static bool isValidDate(dynamic dateValue) {
    try {
      parseDate(dateValue);
      return true;
    } catch (e) {
      return false;
    }
  }
}
