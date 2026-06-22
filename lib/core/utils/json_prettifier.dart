import 'dart:convert';

class JsonPrettifier {
  static String prettify(dynamic data) {
    if (data == null) return '';
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
