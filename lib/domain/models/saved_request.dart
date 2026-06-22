class SavedRequest {
  final String id;
  final String name;
  final String method;
  final String url;
  final List<MapEntry<String, String>> headers;
  final String body;
  final DateTime timestamp;

  SavedRequest({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'url': url,
      'headers': headers.map((e) => {'key': e.key, 'value': e.value}).toList(),
      'body': body,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SavedRequest.fromJson(Map<String, dynamic> json) {
    var headersList = json['headers'] as List? ?? [];
    List<MapEntry<String, String>> parsedHeaders = headersList.map((e) {
      return MapEntry<String, String>(
        e['key']?.toString() ?? '',
        e['value']?.toString() ?? '',
      );
    }).toList();

    return SavedRequest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      method: json['method'] ?? 'GET',
      url: json['url'] ?? '',
      headers: parsedHeaders,
      body: json['body'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
