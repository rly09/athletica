import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/supabase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _animate = false;
  int _selectedIndex = 0;

  late Future<Map<String, dynamic>?> _profile;
  late Future<Map<String, dynamic>?> _stats;
  late Future<List<Map<String, dynamic>>> _events;

  final List<Widget> _pages = [
    const Center(child: Text("🏠 Dashboard Page")),
    const Center(child: Text("💪 Workouts Page")),
    const Center(child: Text("👥 Community Page")),
    const Center(child: Text("🙍 Profile Page")),
  ];

  @override
  void initState() {
    super.initState();
    _profile = SupabaseService().getProfile();
    _stats = SupabaseService().getTodayStats();
    _events = SupabaseService().getEvents();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardContent(),
            _pages[1],
            _pages[2],
            _pages[3],
          ],
        ),
      ),

      // 🔹 Sliding Highlight Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth / 4; // 4 items
            return Stack(
              alignment: Alignment.center,
              children: [
                // Sliding Highlight
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  left: _selectedIndex * width,
                  child: Container(
                    width: width,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Nav Items Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.dashboard, "Dashboard", 0),
                    _buildNavItem(Icons.fitness_center, "Workouts", 1),
                    _buildNavItem(Icons.people, "Community", 2),
                    _buildNavItem(Icons.person, "Profile", 3),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// -------------------------
  /// 🔹 Dashboard Content
  /// -------------------------
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header with Profile
          FutureBuilder<Map<String, dynamic>?>(
            future: _profile,
            builder: (context, snapshot) {
              final name =
              snapshot.hasData ? snapshot.data != null?['full_name'] ?? "Athlete" : "Loading..." : "Loading...";
              return AnimatedSlide(
                offset: _animate ? Offset.zero : const Offset(0, -0.2),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _animate ? 1 : 0,
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome back,",
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text("$name 👋",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage("assets/icons/boy_profile.png"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 🔹 Stats Cards
          FutureBuilder<Map<String, dynamic>?>(
            future: _stats,
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildAnimatedStat(
                      0,
                      "Today’s Workout",
                      "${stats['workout_minutes'] ?? 0} min",
                      Icons.fitness_center,
                      Colors.blue),
                  _buildAnimatedStat(
                      1,
                      "Calories Burned",
                      "${stats['calories'] ?? 0} kcal",
                      Icons.local_fire_department,
                      Colors.red),
                  _buildAnimatedStat(
                      2,
                      "Active Hours",
                      "${stats['active_hours'] ?? 0} hrs",
                      Icons.access_time,
                      Colors.orange),
                  _buildAnimatedStat(3, "Streak", "${stats['streak'] ?? 0} days",
                      Icons.bolt, Colors.green),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // 🔹 Weekly Progress Chart (static for now)
          AnimatedOpacity(
            opacity: _animate ? 1 : 0,
            duration: const Duration(milliseconds: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Weekly Progress",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          spots: const [
                            FlSpot(0, 1),
                            FlSpot(1, 1.5),
                            FlSpot(2, 1.4),
                            FlSpot(3, 2.2),
                            FlSpot(4, 2.8),
                            FlSpot(5, 2.5),
                            FlSpot(6, 3),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Upcoming Events
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _events,
            builder: (context, snapshot) {
              final events = snapshot.data ?? [];
              return AnimatedSlide(
                offset: _animate ? Offset.zero : const Offset(0, 0.2),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upcoming Events",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: events.isEmpty
                          ? const Center(child: Text("No events found"))
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final e = events[index];
                          return _buildEventCard(
                            e['title'] ?? "Event",
                            e['event_date'] ?? "",
                            Colors.purple,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// -------------------------
  /// 🔹 Animated Stats
  /// -------------------------
  Widget _buildAnimatedStat(
      int index, String title, String value, IconData icon, Color color) {
    return AnimatedSlide(
      offset: _animate ? Offset.zero : const Offset(0, 0.2),
      duration: Duration(milliseconds: 500 + (index * 200)),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _animate ? 1 : 0,
        duration: Duration(milliseconds: 500 + (index * 200)),
        child: _buildStatCard(title, value, icon, color),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  /// -------------------------
  /// 🔹 Event Cards
  /// -------------------------
  Widget _buildEventCard(String title, String date, Color color) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// -------------------------
  /// 🔹 Custom Bottom Nav Item
  /// -------------------------
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo)),
            ),
          ],
        ),
      ),
    );
  }
}
