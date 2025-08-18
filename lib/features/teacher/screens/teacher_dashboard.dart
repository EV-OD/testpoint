
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';
import 'package:testpoint/providers/teacher_dashboard_provider.dart';
import 'package:testpoint/features/shared/widgets/app_bottom_navigation.dart';
import 'package:testpoint/features/teacher/screens/teacher_profile_screen.dart';
import 'package:testpoint/features/teacher/screens/teacher_settings_screen.dart';
import 'package:testpoint/features/teacher/screens/create_test_screen.dart';
import 'package:testpoint/features/teacher/screens/test_details_screen.dart';
import 'package:testpoint/features/teacher/screens/view_questions_screen.dart';
import 'package:testpoint/features/teacher/screens/test_results_screen.dart';
import 'package:testpoint/features/teacher/widgets/test_list_view.dart';
import 'package:testpoint/models/test_model.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  NavigationItem _selectedItem = NavigationItem.dashboard;

  @override
  void initState() {
    super.initState();
    // Tests will be loaded in the Consumer builder when needed
  }

  Widget _buildSelectedScreen() {
    switch (_selectedItem) {
      case NavigationItem.dashboard:
        return _buildDashboardContent();
      case NavigationItem.profile:
        return const TeacherProfileScreen();
      case NavigationItem.settings:
        return const TeacherSettingsScreen();
    }
  }

  Widget _buildDashboardContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Drafts'),
              Tab(text: 'Published'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTestList(status: TestStatus.draft),
                _buildTestList(status: TestStatus.published),
                _buildTestList(status: TestStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList({required TestStatus status}) {
    return Consumer<TeacherDashboardProvider>(
      builder: (context, dashboardProvider, child) {
        // Load tests on first build if not already loaded
        if (!dashboardProvider.hasInitiallyLoaded && 
            !dashboardProvider.isLoading && 
            dashboardProvider.errorMessage == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dashboardProvider.loadTeacherTests();
          });
        }

        if (dashboardProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (dashboardProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading tests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  dashboardProvider.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    dashboardProvider.clearError();
                    dashboardProvider.refreshTests();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tests = dashboardProvider.getTestsByStatus(status);

        return RefreshIndicator(
          onRefresh: dashboardProvider.refreshTests,
          child: TestListView(
            tests: tests,
            testStatus: status,
            onTestAction: _handleTestAction,
          ),
        );
      },
    );
  }

  Future<void> _handleTestAction(String action, Test test) async {
    try {
      final dashboardProvider = Provider.of<TeacherDashboardProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateTestScreen(testId: test.id),
          ),
        ).then((_) {
          // Refresh tests when returning from edit screen
          dashboardProvider.refreshTests();
        });
        break;
        
      case 'delete':
        final confirmed = await _showDeleteConfirmation(test);
        if (confirmed == true) {
          final success = await dashboardProvider.deleteTest(test.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted && dashboardProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dashboardProvider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
        
      case 'publish':
        final confirmed = await _showPublishConfirmation(test);
        if (confirmed == true) {
          final success = await dashboardProvider.publishTest(test.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test published successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted && dashboardProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dashboardProvider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
        
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TestDetailsScreen(test: test),
          ),
        );
        break;
        
      case 'restore_to_draft':
        final confirmed = await _showRestoreToDraftConfirmation(test);
        if (confirmed == true) {
          final success = await dashboardProvider.restoreToDraft(test.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Test restored to draft successfully'),
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.amber.shade600 
                    : Colors.amber.shade700,
              ),
            );
          } else if (mounted && dashboardProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dashboardProvider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
        
      case 'view_questions':
        final questions = await dashboardProvider.viewTestQuestions(test.id);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewQuestionsScreen(
                testId: test.id,
                testName: test.name,
                questions: questions,
              ),
            ),
          );
        }
        break;
        
      case 'view_results':
        final sessions = await dashboardProvider.viewTestResults(test.id);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TestResultsScreen(
                test: test,
                sessions: sessions,
              ),
            ),
          );
        }
        break;
        
      case 'revert_to_draft':
        final confirmed = await _showRevertToDraftConfirmation(test);
        if (confirmed == true) {
          final success = await dashboardProvider.restoreToDraftWithCleanup(test.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Test reverted to draft successfully. All student submissions have been removed.'),
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.amber.shade600 
                    : Colors.amber.shade700,
              ),
            );
          } else if (mounted && dashboardProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dashboardProvider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
        
      case 'end_quiz':
        final confirmed = await _showEndQuizConfirmation(test);
        if (confirmed == true) {
          final success = await dashboardProvider.endQuiz(test.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz ended successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted && dashboardProvider.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dashboardProvider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
    }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(Test test) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test'),
        content: Text(
          'Are you sure you want to delete "${test.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPublishConfirmation(Test test) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Test'),
        content: Text(
          'Are you sure you want to publish "${test.name}"? Once published, students will be able to take it at the scheduled time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRestoreToDraftConfirmation(Test test) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore to Draft'),
        content: Text(
          'Are you sure you want to restore "${test.name}" to draft status? This will make it unavailable to students and allow you to edit it again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.amber.shade600 
                  : Colors.amber.shade700,
            ),
            child: const Text('Restore to Draft'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRevertToDraftConfirmation(Test test) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revert to Draft'),
        content: Text(
          'Are you sure you want to revert "${test.name}" to draft status?\n\n⚠️ WARNING: This will permanently delete ALL student submissions and results for this test. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.amber.shade600 
                  : Colors.amber.shade700,
            ),
            child: const Text('Revert to Draft'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showEndQuizConfirmation(Test test) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Quiz'),
        content: Text(
          'Are you sure you want to end "${test.name}" immediately?\n\nStudents who are currently taking the test will have their current progress automatically submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.red.shade400 
                  : Colors.red.shade700,
            ),
            child: const Text('End Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'TestPoint',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildSelectedScreen(),
      floatingActionButton: _selectedItem == NavigationItem.dashboard
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTestScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Test'),
            )
          : null,
      bottomNavigationBar: AppBottomNavigation(
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() {
            _selectedItem = item;
          });
        },
      ),
    );
  }
}
