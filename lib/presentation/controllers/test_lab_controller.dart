import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/utils/curl_converter.dart';
import '../../core/utils/json_prettifier.dart';
import '../../data/services/http_service.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/saved_request.dart';

class HeaderInput {
  final TextEditingController keyController;
  final TextEditingController valueController;

  HeaderInput({String key = '', String value = ''})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class TestLabController extends ChangeNotifier {
  final HttpService _httpService;
  final StorageService _storageService;

  // Request State
  final TextEditingController urlController = TextEditingController(
    text: 'https://jsonplaceholder.typicode.com/posts/1',
  );
  final TextEditingController bodyController = TextEditingController();
  
  String selectedMethod = 'GET';
  final List<HeaderInput> headers = [
    HeaderInput(key: 'Content-Type', value: 'application/json'),
  ];

  // UI State
  bool isSidebarVisible = true;
  bool isLoading = false;

  // Response State
  Response? response;
  DioException? error;
  int? responseTimeMs;
  String? formattedResponseBody;

  // Lists
  List<SavedRequest> savedRequests = [];
  List<SavedRequest> historyRequests = [];

  final List<String> methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  static const int _kMaxHistorySize = 20;

  TestLabController({
    required HttpService httpService,
    required StorageService storageService,
  })  : _httpService = httpService,
        _storageService = storageService;

  Future<void> init() async {
    await _storageService.init();
    loadSavedAndHistory();
  }

  void loadSavedAndHistory() {
    savedRequests = _storageService.getSavedRequests();
    historyRequests = _storageService.getHistoryRequests();
    notifyListeners();
  }

  void toggleSidebar() {
    isSidebarVisible = !isSidebarVisible;
    notifyListeners();
  }

  void addHeader() {
    headers.add(HeaderInput());
    notifyListeners();
  }

  void removeHeader(int index) {
    headers[index].dispose();
    headers.removeAt(index);
    notifyListeners();
  }

  void prettifyJsonBody() {
    final text = bodyController.text.trim();
    if (text.isEmpty) return;
    final decoded = jsonDecode(text); // throws FormatException on bad JSON — callers handle it
    bodyController.text = const JsonEncoder.withIndent('  ').convert(decoded);
    notifyListeners();
  }

  Future<void> sendRequest() async {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    isLoading = true;
    response = null;
    error = null;
    formattedResponseBody = null;
    responseTimeMs = null;
    notifyListeners();

    _addToHistory();

    final stopwatch = Stopwatch()..start();

    // Prepare headers
    final Map<String, dynamic> requestHeaders = {};
    for (var header in headers) {
      final key = header.keyController.text.trim();
      final val = header.valueController.text.trim();
      if (key.isNotEmpty) {
        requestHeaders[key] = val;
      }
    }

    // Prepare body
    dynamic requestBody = bodyController.text;
    if (requestBody.toString().isNotEmpty) {
      try {
        if (requestHeaders.entries.any((e) =>
            e.key.toLowerCase() == 'content-type' &&
            e.value.toString().toLowerCase().contains('json'))) {
          requestBody = jsonDecode(bodyController.text);
        }
      } catch (_) {}
    } else {
      requestBody = null;
    }

    try {
      final res = await _httpService.request(
        url: url,
        method: selectedMethod,
        headers: requestHeaders,
        data: requestBody,
      );

      stopwatch.stop();
      response = res;
      responseTimeMs = stopwatch.elapsedMilliseconds;
      formattedResponseBody = JsonPrettifier.prettify(res.data);
    } on DioException catch (e) {
      stopwatch.stop();
      error = e;
      responseTimeMs = stopwatch.elapsedMilliseconds;
      if (e.response != null) {
        response = e.response;
        formattedResponseBody = JsonPrettifier.prettify(e.response?.data);
      }
    } catch (e) {
      stopwatch.stop();
      error = DioException(
        requestOptions: RequestOptions(path: url),
        error: e.toString(),
        type: DioExceptionType.unknown,
      );
      responseTimeMs = stopwatch.elapsedMilliseconds;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _addToHistory() {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    final newHist = _buildSavedRequest('$selectedMethod $url');
    historyRequests.removeWhere((e) => e.url == newHist.url && e.method == newHist.method);
    historyRequests.insert(0, newHist);
    if (historyRequests.length > _kMaxHistorySize) {
      historyRequests.removeLast();
    }
    _storageService.saveHistory(historyRequests);
    notifyListeners();
  }

  void saveCurrentRequest(String name) {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    savedRequests.add(_buildSavedRequest(name));
    _storageService.saveRequests(savedRequests);
    notifyListeners();
  }

  /// Builds a [SavedRequest] snapshot from the current UI state.
  SavedRequest _buildSavedRequest(String name) {
    return SavedRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      method: selectedMethod,
      url: urlController.text.trim(),
      headers: headers
          .map((h) => MapEntry(h.keyController.text, h.valueController.text))
          .toList(),
      body: bodyController.text,
      timestamp: DateTime.now(),
    );
  }

  void deleteSavedRequest(String id) {
    savedRequests.removeWhere((e) => e.id == id);
    _storageService.saveRequests(savedRequests);
    notifyListeners();
  }

  void clearHistory() {
    historyRequests.clear();
    _storageService.saveHistory(historyRequests);
    notifyListeners();
  }

  void loadRequest(SavedRequest req) {
    selectedMethod = methods.contains(req.method) ? req.method : 'GET';
    urlController.text = req.url;

    for (var h in headers) {
      h.dispose();
    }
    headers.clear();
    for (var header in req.headers) {
      headers.add(HeaderInput(key: header.key, value: header.value));
    }
    bodyController.text = req.body;
    notifyListeners();
  }

  void importFromCurl(String curlString) {
    final parsed = CurlConverter.parse(curlString);
    final String method = parsed['method'] ?? 'GET';
    final String url = parsed['url'] ?? '';
    final Map<String, String> parsedHeaders = parsed['headers'] ?? {};
    final String body = parsed['body'] ?? '';

    selectedMethod = methods.contains(method) ? method : 'GET';
    if (url.isNotEmpty) {
      urlController.text = url;
    }

    for (var h in headers) {
      h.dispose();
    }
    headers.clear();

    if (parsedHeaders.isEmpty) {
      if (body.trim().startsWith('{') || body.trim().startsWith('[')) {
        headers.add(HeaderInput(key: 'Content-Type', value: 'application/json'));
      }
    } else {
      parsedHeaders.forEach((k, v) {
        headers.add(HeaderInput(key: k, value: v));
      });
    }

    if (body.isNotEmpty) {
      bodyController.text = body;
      try {
        final decoded = jsonDecode(body);
        bodyController.text = const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {}
    } else {
      bodyController.text = '';
    }

    notifyListeners();
  }

  String getGeneratedCurl(String format) {
    return CurlConverter.export(
      url: urlController.text.trim(),
      method: selectedMethod,
      headers: headers.map((h) => MapEntry(h.keyController.text, h.valueController.text)).toList(),
      body: bodyController.text,
      format: format,
    );
  }

  @override
  void dispose() {
    urlController.dispose();
    bodyController.dispose();
    for (var header in headers) {
      header.dispose();
    }
    super.dispose();
  }
}
