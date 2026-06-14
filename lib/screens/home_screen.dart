import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../services/storage_service.dart';
import '../widgets/progress_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/focus_stats_bar.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];
  List<FocusSession> _focusSessions = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<String> _categories = ['All', 'Mind', 'Work', 'Health', 'Personal'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _storageService.loadTasks();
    final sessions = await _storageService.loadFocusSessions();
    setState(() {
      _tasks = tasks;
      _focusSessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_tasks);
  }

  Future<void> _saveSessions() async {
    await _storageService.saveFocusSessions(_focusSessions);
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() {
        _tasks.removeAt(index);
      });
      _saveTasks();

      // Show Undo SnackBar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${task.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              setState(() {
                _tasks.insert(index, task);
              });
              _saveTasks();
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
    });
    _saveTasks();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task added successfully'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _recordFocusSession(FocusSession session, Task? updatedTask) {
    setState(() {
      _focusSessions.insert(0, session);
      if (updatedTask != null) {
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      }
    });
    _saveSessions();
    _saveTasks();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 🌅';
    } else if (hour < 17) {
      return 'Good Afternoon ☀️';
    } else {
      return 'Good Evening 🌌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter tasks based on category selection
    final filteredTasks = _selectedCategory == 'All'
        ? _tasks
        : _tasks.where((t) => t.category == _selectedCategory).toList();

    // Stats calculations
    final totalCount = _tasks.length;
    final completedCount = _tasks.where((t) => t.isCompleted).toList().length;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Title / Date Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.timer_outlined, color: Colors.white54),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TimerScreen(
                                        onSessionComplete: _recordFocusSession,
                                      ),
                                    ),
                                  );
                                },
                                tooltip: 'Start focus timer',
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white54),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _loadData();
                                },
                                tooltip: 'Sync data',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Progress Analytics Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: ProgressCard(
                        completedCount: completedCount,
                        totalCount: totalCount,
                      ),
                    ),
                  ),

                  // Focus Balance Statistics Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: FocusStatsBar(sessions: _focusSessions),
                    ),
                  ),

                  // Category Header & List Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          CategorySelector(
                            selectedCategory: _selectedCategory,
                            categories: _categories,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Task stream label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Focus List',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          if (filteredTasks.isNotEmpty)
                            Text(
                              '${filteredTasks.length} total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Tasks list or empty state
                  filteredTasks.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.self_improvement,
                                    size: 80,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Stream is clear',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No tasks in $_selectedCategory. Take a deep breath and enjoy the moment.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.4),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final task = filteredTasks[index];
                                return TaskTile(
                                  task: task,
                                  onToggle: () => _toggleTask(task),
                                  onDelete: () => _deleteTask(task),
                                  onStartTimer: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TimerScreen(
                                          task: task,
                                          onSessionComplete: _recordFocusSession,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: filteredTasks.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTaskSheet(onTaskCreated: _addTask),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
