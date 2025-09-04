import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // Get user profile
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // Get today's stats
  Future<Map<String, dynamic>?> getTodayStats() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('stats')
        .select()
        .eq('user_id', userId)
        .eq('created_at', DateTime.now().toIso8601String().substring(0,10))
        .maybeSingle();
    return response;
  }

  // Get upcoming events
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await supabase
        .from('events')
        .select()
        .gte('event_date', DateTime.now().toIso8601String().substring(0,10));
    return List<Map<String, dynamic>>.from(response);
  }
}
