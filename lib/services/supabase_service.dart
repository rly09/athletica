import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  /// 🔹 Get Profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  /// 🔹 Get Today Stats
  Future<Map<String, dynamic>?> getTodayStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('stats')
        .select()
        .eq('user_id', user.id)
        .eq('created_at', DateTime.now().toIso8601String().substring(0, 10))
        .maybeSingle();

    return response;
  }

  /// 🔹 Get Weekly Stats (last 7 days)
  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));

    final response = await _supabase
        .from('stats')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', weekAgo.toIso8601String().substring(0, 10))
        .lte('created_at', today.toIso8601String().substring(0, 10))
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Get Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .gte('event_date', DateTime.now().toIso8601String().substring(0, 10))
        .order('event_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
