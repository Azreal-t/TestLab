import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/saved_request.dart';

abstract class StorageService {
  Future<void> init();
  List<SavedRequest> getSavedRequests();
  Future<void> saveRequests(List<SavedRequest> requests);
  List<SavedRequest> getHistoryRequests();
  Future<void> saveHistory(List<SavedRequest> history);
}

class SharedPrefsStorageService implements StorageService {
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  List<SavedRequest> getSavedRequests() {
    final list = _prefs.getStringList('saved_requests') ?? [];
    return list.map((e) => SavedRequest.fromJson(jsonDecode(e))).toList();
  }

  @override
  Future<void> saveRequests(List<SavedRequest> requests) async {
    final list = requests.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('saved_requests', list);
  }

  @override
  List<SavedRequest> getHistoryRequests() {
    final list = _prefs.getStringList('history_requests') ?? [];
    return list.map((e) => SavedRequest.fromJson(jsonDecode(e))).toList();
  }

  @override
  Future<void> saveHistory(List<SavedRequest> history) async {
    final list = history.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('history_requests', list);
  }
}
