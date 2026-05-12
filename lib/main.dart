import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appName = 'BONNIER ALAIN JEAN JACQUES';
const developerName = 'BONNIER ALAIN JEAN JACQUES';
const supportEmail = 'support@bonnieralainjeanjacques.com';
const screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  runApp(OperationsApp(initialRoute: initialRoute));
}

class OperationsApp extends StatelessWidget {
  const OperationsApp({
    super.key,
    required this.initialRoute,
    OperationsStore? store,
  }) : store = store ?? const OperationsStore();

  final String initialRoute;
  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: OperationsHome(initialRoute: initialRoute, store: store),
    );
  }
}

class AppTheme {
  static const navy = Color(0xFF000B1A);
  static const deepBlue = Color(0xFF002452);
  static const red = Color(0xFFB70817);
  static const ink = Color(0xFF1E2023);
  static const cream = Color(0xFFF8F3EA);
  static const steel = Color(0xFF4E5F70);

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: red,
          brightness: Brightness.light,
        ).copyWith(
          primary: red,
          onPrimary: Colors.white,
          secondary: deepBlue,
          onSecondary: Colors.white,
          tertiary: ink,
          surface: const Color(0xFFFFFBF7),
          surfaceContainerHighest: cream,
          outline: const Color(0xFFD6CEC3),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF9F6F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2DAD0)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class TrainingCourse {
  const TrainingCourse({
    required this.id,
    required this.title,
    required this.team,
    required this.minutes,
    required this.lessons,
    required this.summary,
  });

  final String id;
  final String title;
  final String team;
  final int minutes;
  final int lessons;
  final String summary;
}

class MaintenanceRequest {
  const MaintenanceRequest({
    required this.id,
    required this.title,
    required this.area,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String title;
  final String area;
  final String priority;
  final String status;
  final DateTime createdAt;
  final String note;

  MaintenanceRequest copyWith({String? status}) {
    return MaintenanceRequest(
      id: id,
      title: title,
      area: area,
      priority: priority,
      status: status ?? this.status,
      createdAt: createdAt,
      note: note,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'area': area,
    'priority': priority,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
  };

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      area: json['area'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String,
    );
  }
}

class EquipmentCheckout {
  const EquipmentCheckout({
    required this.id,
    required this.equipment,
    required this.holder,
    required this.dueAt,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String equipment;
  final String holder;
  final DateTime dueAt;
  final String status;
  final DateTime createdAt;

  EquipmentCheckout copyWith({String? status}) {
    return EquipmentCheckout(
      id: id,
      equipment: equipment,
      holder: holder,
      dueAt: dueAt,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipment': equipment,
    'holder': holder,
    'dueAt': dueAt.toIso8601String(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory EquipmentCheckout.fromJson(Map<String, dynamic> json) {
    return EquipmentCheckout(
      id: json['id'] as String,
      equipment: json['equipment'] as String,
      holder: json['holder'] as String,
      dueAt: DateTime.parse(json['dueAt'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OperationsStore {
  const OperationsStore();

  static const _requestsKey = 'maintenance_requests';
  static const _checkoutsKey = 'equipment_checkouts';
  static const _coursesKey = 'completed_courses';

  Future<OperationsSnapshot> load() async {
    if (screenshotMode) {
      return OperationsSnapshot.samples();
    }

    final prefs = await SharedPreferences.getInstance();
    return OperationsSnapshot(
      requests: _decodeList(
        prefs.getString(_requestsKey),
        MaintenanceRequest.fromJson,
      ),
      checkouts: _decodeList(
        prefs.getString(_checkoutsKey),
        EquipmentCheckout.fromJson,
      ),
      completedCourseIds: prefs.getStringList(_coursesKey) ?? const [],
    ).withFallbackSamples();
  }

  Future<void> saveRequests(List<MaintenanceRequest> requests) async {
    if (screenshotMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _requestsKey,
      jsonEncode(requests.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> saveCheckouts(List<EquipmentCheckout> checkouts) async {
    if (screenshotMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _checkoutsKey,
      jsonEncode(checkouts.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> saveCompletedCourses(List<String> courseIds) async {
    if (screenshotMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_coursesKey, courseIds);
  }

  static List<T> _decodeList<T>(
    String? encoded,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (encoded == null || encoded.isEmpty) return const [];
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class OperationsSnapshot {
  const OperationsSnapshot({
    required this.requests,
    required this.checkouts,
    required this.completedCourseIds,
  });

  final List<MaintenanceRequest> requests;
  final List<EquipmentCheckout> checkouts;
  final List<String> completedCourseIds;

  OperationsSnapshot withFallbackSamples() {
    return OperationsSnapshot(
      requests: requests.isEmpty ? sampleRequests : requests,
      checkouts: checkouts.isEmpty ? sampleCheckouts : checkouts,
      completedCourseIds: completedCourseIds,
    );
  }

  factory OperationsSnapshot.samples() {
    return OperationsSnapshot(
      requests: sampleRequests,
      checkouts: sampleCheckouts,
      completedCourseIds: const ['opening-standards', 'cash-control'],
    );
  }
}

class OperationsController extends ChangeNotifier {
  OperationsController(this._store);

  final OperationsStore _store;
  var _loaded = false;
  var requests = <MaintenanceRequest>[];
  var checkouts = <EquipmentCheckout>[];
  var completedCourseIds = <String>{};

  bool get loaded => _loaded;

  Future<void> load() async {
    final snapshot = await _store.load();
    requests = List.of(snapshot.requests);
    checkouts = List.of(snapshot.checkouts);
    completedCourseIds = snapshot.completedCourseIds.toSet();
    _loaded = true;
    notifyListeners();
  }

  bool isCourseComplete(String id) => completedCourseIds.contains(id);

  Future<void> toggleCourse(String id) async {
    if (completedCourseIds.contains(id)) {
      completedCourseIds.remove(id);
    } else {
      completedCourseIds.add(id);
    }
    notifyListeners();
    await _store.saveCompletedCourses(completedCourseIds.toList()..sort());
  }

  Future<void> addRequest({
    required String title,
    required String area,
    required String priority,
    required String note,
  }) async {
    requests = [
      MaintenanceRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        area: area,
        priority: priority,
        status: 'Open',
        createdAt: DateTime.now(),
        note: note,
      ),
      ...requests,
    ];
    notifyListeners();
    await _store.saveRequests(requests);
  }

  Future<void> updateRequestStatus(String id, String status) async {
    requests = [
      for (final request in requests)
        request.id == id ? request.copyWith(status: status) : request,
    ];
    notifyListeners();
    await _store.saveRequests(requests);
  }

  Future<void> addCheckout({
    required String equipment,
    required String holder,
    required DateTime dueAt,
  }) async {
    checkouts = [
      EquipmentCheckout(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        equipment: equipment,
        holder: holder,
        dueAt: dueAt,
        status: 'Checked out',
        createdAt: DateTime.now(),
      ),
      ...checkouts,
    ];
    notifyListeners();
    await _store.saveCheckouts(checkouts);
  }

  Future<void> updateCheckoutStatus(String id, String status) async {
    checkouts = [
      for (final checkout in checkouts)
        checkout.id == id ? checkout.copyWith(status: status) : checkout,
    ];
    notifyListeners();
    await _store.saveCheckouts(checkouts);
  }
}

class OperationsHome extends StatefulWidget {
  const OperationsHome({
    super.key,
    required this.initialRoute,
    required this.store,
  });

  final String initialRoute;
  final OperationsStore store;

  @override
  State<OperationsHome> createState() => _OperationsHomeState();
}

class _OperationsHomeState extends State<OperationsHome> {
  late final OperationsController controller;
  late int selectedIndex;
  late bool settingsOpen;

  @override
  void initState() {
    super.initState();
    selectedIndex = _indexForRoute(widget.initialRoute);
    settingsOpen = widget.initialRoute.contains('settings');
    controller = OperationsController(widget.store)..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int _indexForRoute(String route) {
    if (route.contains('training')) return 1;
    if (route.contains('revenue')) return 2;
    if (route.contains('maintenance')) return 3;
    if (route.contains('equipment')) return 4;
    return 0;
  }

  String get _title {
    if (settingsOpen) return 'Settings';
    return switch (selectedIndex) {
      0 => 'Operations',
      1 => 'Training',
      2 => 'Revenue',
      3 => 'Maintenance',
      4 => 'Equipment',
      _ => 'Operations',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.loaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_title),
            actions: [
              IconButton(
                key: const Key('settings-button'),
                tooltip: 'Settings',
                onPressed: () => setState(() => settingsOpen = true),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: settingsOpen
                ? SettingsScreen(
                    onClose: () {
                      setState(() => settingsOpen = false);
                    },
                  )
                : _bodyForIndex(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
                settingsOpen = false;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Courses',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Revenue',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: 'Requests',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Equipment',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bodyForIndex() {
    return switch (selectedIndex) {
      0 => DashboardScreen(
        controller: controller,
        onSelect: (index) => setState(() => selectedIndex = index),
      ),
      1 => TrainingScreen(controller: controller),
      2 => RevenueScreen(controller: controller),
      3 => MaintenanceScreen(controller: controller),
      4 => EquipmentScreen(controller: controller),
      _ => DashboardScreen(
        controller: controller,
        onSelect: (index) => setState(() => selectedIndex = index),
      ),
    };
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onSelect,
  });

  final OperationsController controller;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final completed = trainingCourses
        .where((course) => controller.isCourseComplete(course.id))
        .length;
    final openRequests = controller.requests
        .where((item) => item.status != 'Resolved')
        .length;
    final activeCheckouts = controller.checkouts
        .where((item) => item.status != 'Returned')
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.asset(
                'docs/featured.png',
                height: 188,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Training, revenue, maintenance, and checkout work in one local operations console.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Courses complete',
                value: '$completed/${trainingCourses.length}',
                icon: Icons.school,
                color: AppTheme.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Open requests',
                value: '$openRequests',
                icon: Icons.build,
                color: AppTheme.deepBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Active checkouts',
                value: '$activeCheckouts',
                icon: Icons.inventory_2,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Weekly revenue',
                value: '42.8k',
                icon: Icons.trending_up,
                color: AppTheme.steel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Today', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ActionTile(
          icon: Icons.school_outlined,
          title: 'Continue staff training',
          subtitle: 'Two courses are ready for review.',
          button: 'Open',
          onTap: () => onSelect(1),
        ),
        const SizedBox(height: 8),
        ActionTile(
          icon: Icons.analytics_outlined,
          title: 'Check revenue movement',
          subtitle: 'Compare service lines and weekly pacing.',
          button: 'View',
          onTap: () => onSelect(2),
        ),
        const SizedBox(height: 8),
        ActionTile(
          icon: Icons.build_outlined,
          title: 'Maintenance queue',
          subtitle: '$openRequests items need scheduling or resolution.',
          button: 'Manage',
          onTap: () => onSelect(3),
        ),
      ],
    );
  }
}

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemBuilder: (context, index) {
        final course = trainingCourses[index];
        final complete = controller.isCourseComplete(course.id);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseBadge(complete: complete),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text('${course.team} team | ${course.minutes} min'),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: complete,
                      onChanged: (_) => controller.toggleCourse(course.id),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(course.summary),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: complete ? 1 : math.min(0.28 + index * 0.14, 0.86),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showCourseDetail(context, course, complete),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Course brief'),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemCount: trainingCourses.length,
    );
  }

  void _showCourseDetail(
    BuildContext context,
    TrainingCourse course,
    bool complete,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: Text(
          '${course.summary}\n\nLessons: ${course.lessons}\nStatus: ${complete ? 'Complete' : 'In progress'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: const [
            Expanded(
              child: MetricCard(
                label: 'Month to date',
                value: '184.6k',
                icon: Icons.payments_outlined,
                color: AppTheme.red,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                label: 'Average ticket',
                value: '312',
                icon: Icons.receipt_long_outlined,
                color: AppTheme.deepBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weekly performance by completed service and equipment activity.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: RevenueChartPainter(
                      values: const [28, 34, 31, 39, 35, 43, 48, 52],
                      lineColor: Theme.of(context).colorScheme.primary,
                      fillColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Focus areas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const StatusRow(
          icon: Icons.trending_up,
          title: 'Training completion is lifting service throughput',
          status: '+8 percent vs last period',
        ),
        const SizedBox(height: 8),
        const StatusRow(
          icon: Icons.inventory_2_outlined,
          title: 'Checkout visibility reduced idle equipment time',
          status: '4 assets active',
        ),
        const SizedBox(height: 8),
        StatusRow(
          icon: Icons.build_outlined,
          title: 'Maintenance requests awaiting completion',
          status: '${controller.requests.length} tracked locally',
        ),
      ],
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FilledButton.icon(
          key: const Key('new-request-button'),
          onPressed: () => _showRequestForm(context),
          icon: const Icon(Icons.add),
          label: const Text('New maintenance request'),
        ),
        const SizedBox(height: 14),
        for (final request in controller.requests) ...[
          MaintenanceCard(
            request: request,
            onStatusChanged: (status) =>
                controller.updateRequestStatus(request.id, status),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _showRequestForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final areaController = TextEditingController();
    final noteController = TextEditingController();
    var priority = 'High';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maintenance request',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('request-title-field'),
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Issue'),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('request-area-field'),
                      controller: areaController,
                      decoration: const InputDecoration(labelText: 'Area'),
                      validator: _required,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => priority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const Key('request-note-field'),
                      controller: noteController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('save-request-button'),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          await controller.addRequest(
                            title: titleController.text.trim(),
                            area: areaController.text.trim(),
                            priority: priority,
                            note: noteController.text.trim(),
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save request'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FilledButton.icon(
          key: const Key('new-checkout-button'),
          onPressed: () => _showCheckoutForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Create checkout'),
        ),
        const SizedBox(height: 14),
        for (final checkout in controller.checkouts) ...[
          EquipmentCard(
            checkout: checkout,
            onStatusChanged: (status) =>
                controller.updateCheckoutStatus(checkout.id, status),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _showCheckoutForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final equipmentController = TextEditingController();
    final holderController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equipment checkout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('equipment-field'),
                  controller: equipmentController,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('holder-field'),
                  controller: holderController,
                  decoration: const InputDecoration(labelText: 'Assigned to'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('save-checkout-button'),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await controller.addCheckout(
                        equipment: equipmentController.text.trim(),
                        holder: holderController.text.trim(),
                        dueAt: DateTime.now().add(const Duration(days: 3)),
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('Save checkout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset('docs/icon.png', width: 58, height: 58),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      const Text('Local operations workspace'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SettingsTile(
          icon: Icons.lock_outline,
          title: 'Local storage only',
          subtitle:
              'Training progress, requests, checkout records, and preferences stay on this device.',
        ),
        const SizedBox(height: 8),
        const SettingsTile(
          icon: Icons.cloud_off_outlined,
          title: 'No account or cloud sync',
          subtitle:
              'The app does not send records to servers and does not use analytics, ads, or external services.',
        ),
        const SizedBox(height: 8),
        const SettingsTile(
          icon: Icons.support_agent_outlined,
          title: 'Support',
          subtitle: '$developerName\n$supportEmail',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onClose,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to operations'),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navy,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: TextButton(onPressed: onTap, child: Text(button)),
        onTap: onTap,
      ),
    );
  }
}

class CourseBadge extends StatelessWidget {
  const CourseBadge({super.key, required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: complete ? AppTheme.red : AppTheme.deepBlue,
      foregroundColor: Colors.white,
      child: Icon(complete ? Icons.done : Icons.play_arrow),
    );
  }
}

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({
    super.key,
    required this.request,
    required this.onStatusChanged,
  });

  final MaintenanceRequest request;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                PriorityChip(label: request.priority),
              ],
            ),
            const SizedBox(height: 6),
            Text('${request.area} | ${_formatDate(request.createdAt)}'),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.note),
            ],
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Open', label: Text('Open')),
                ButtonSegment(value: 'Scheduled', label: Text('Scheduled')),
                ButtonSegment(value: 'Resolved', label: Text('Resolved')),
              ],
              selected: {request.status},
              onSelectionChanged: (selection) =>
                  onStatusChanged(selection.first),
            ),
          ],
        ),
      ),
    );
  }
}

class EquipmentCard extends StatelessWidget {
  const EquipmentCard({
    super.key,
    required this.checkout,
    required this.onStatusChanged,
  });

  final EquipmentCheckout checkout;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: AppTheme.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    checkout.equipment,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Assigned to ${checkout.holder}'),
            Text('Due ${_formatDate(checkout.dueAt)}'),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Checked out',
                  label: Text('Out'),
                  icon: Icon(Icons.logout),
                ),
                ButtonSegment(
                  value: 'Returned',
                  label: Text('Returned'),
                  icon: Icon(Icons.assignment_return),
                ),
              ],
              selected: {checkout.status},
              onSelectionChanged: (selection) =>
                  onStatusChanged(selection.first),
            ),
          ],
        ),
      ),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'High' => AppTheme.red,
      'Medium' => AppTheme.deepBlue,
      _ => AppTheme.steel,
    };
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }
}

class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(status),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  RevenueChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE4DBD0)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (i + 1) / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(maxValue - minValue, 1);
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y =
          size.height -
          ((values[i] - minValue) / range * (size.height * 0.72) +
              size.height * 0.14);
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = fillColor.withValues(alpha: 0.10),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = AppTheme.navy);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant RevenueChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

const trainingCourses = [
  TrainingCourse(
    id: 'opening-standards',
    title: 'Opening standards',
    team: 'Front line',
    minutes: 22,
    lessons: 4,
    summary:
        'Prepare workstations, verify safety checks, and align staff handoff notes before opening.',
  ),
  TrainingCourse(
    id: 'cash-control',
    title: 'Cash control and closeout',
    team: 'Supervisors',
    minutes: 18,
    lessons: 3,
    summary:
        'Review register handling, closeout checks, variance notes, and manager approval steps.',
  ),
  TrainingCourse(
    id: 'equipment-care',
    title: 'Equipment care',
    team: 'Operations',
    minutes: 26,
    lessons: 5,
    summary:
        'Keep high-use equipment ready with checkout logs, cleaning routines, and issue reporting.',
  ),
  TrainingCourse(
    id: 'service-recovery',
    title: 'Service recovery',
    team: 'All staff',
    minutes: 16,
    lessons: 3,
    summary:
        'Use clear escalation notes and follow-up tasks when customer work needs extra attention.',
  ),
];

final sampleRequests = [
  MaintenanceRequest(
    id: 'req-1',
    title: 'Replace loading bay safety light',
    area: 'Back entrance',
    priority: 'High',
    status: 'Scheduled',
    createdAt: DateTime(2026, 5, 9),
    note: 'Technician assigned for the next opening block.',
  ),
  MaintenanceRequest(
    id: 'req-2',
    title: 'Inspect training room projector',
    area: 'Staff training room',
    priority: 'Medium',
    status: 'Open',
    createdAt: DateTime(2026, 5, 10),
    note: 'Image flickers after 20 minutes of use.',
  ),
  MaintenanceRequest(
    id: 'req-3',
    title: 'Tighten checkout cart handle',
    area: 'Equipment storage',
    priority: 'Low',
    status: 'Resolved',
    createdAt: DateTime(2026, 5, 6),
    note: 'Resolved during morning walkthrough.',
  ),
];

final sampleCheckouts = [
  EquipmentCheckout(
    id: 'eq-1',
    equipment: 'Inventory scanner A12',
    holder: 'M. Leroy',
    dueAt: DateTime(2026, 5, 13),
    status: 'Checked out',
    createdAt: DateTime(2026, 5, 11),
  ),
  EquipmentCheckout(
    id: 'eq-2',
    equipment: 'Portable label printer',
    holder: 'S. Martin',
    dueAt: DateTime(2026, 5, 14),
    status: 'Checked out',
    createdAt: DateTime(2026, 5, 10),
  ),
  EquipmentCheckout(
    id: 'eq-3',
    equipment: 'Training tablet set',
    holder: 'Operations desk',
    dueAt: DateTime(2026, 5, 12),
    status: 'Returned',
    createdAt: DateTime(2026, 5, 8),
  ),
];
