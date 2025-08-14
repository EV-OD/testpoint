import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/features/teacher/widgets/test_basic_info_step.dart';
import 'package:testpoint/features/teacher/widgets/question_creation_step.dart';
import 'package:testpoint/features/teacher/widgets/test_preview_step.dart';

class CreateTestScreen extends StatefulWidget {
  final String? testId; // For editing existing tests

  const CreateTestScreen({
    super.key,
    this.testId,
  });

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize test provider after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTestProvider();
    });
  }

  void _initializeTestProvider() async {
    final testProvider = Provider.of<TestProvider>(context, listen: false);
    
    if (widget.testId != null) {
      // Load existing test for editing
      final test = await testProvider.getTestById(widget.testId!);
      if (test != null) {
        testProvider.loadTestForEditing(test);
      }
    } else {
      // Start new test creation
      testProvider.startNewTest();
    }
    
    // Load available groups
    await testProvider.loadAvailableGroups();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.testId != null ? 'Edit Test' : 'Create Test'),
              elevation: 0,
              actions: [
                if (provider.errorMessage != null)
                  IconButton(
                    icon: const Icon(Icons.error_outline, color: Colors.red),
                    onPressed: () {
                      _showErrorDialog(context, provider.errorMessage!);
                    },
                  ),
              ],
            ),
            body: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(provider),
                
                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe
                    onPageChanged: (index) {
                      if (index != provider.currentStep) {
                        provider.goToStep(index);
                      }
                    },
                    children: const [
                      TestBasicInfoStep(),
                      QuestionCreationStep(),
                      TestPreviewStep(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(provider),
              ],
            ),
          );
        },
      );
  }

  Widget _buildProgressIndicator(TestProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: [
              _buildStepIndicator(0, 'Basic Info', provider.currentStep >= 0),
              Expanded(child: _buildStepConnector(provider.currentStep >= 1)),
              _buildStepIndicator(1, 'Questions', provider.currentStep >= 1),
              Expanded(child: _buildStepConnector(provider.currentStep >= 2)),
              _buildStepIndicator(2, 'Preview', provider.currentStep >= 2),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          LinearProgressIndicator(
            value: (provider.currentStep + 1) / 3,
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive 
          ? Theme.of(context).colorScheme.primary 
          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
    );
  }

  Widget _buildNavigationButtons(TestProvider provider) {
    // Don't show navigation buttons on the preview step (step 2)
    // The preview step has its own action buttons
    if (provider.currentStep == 2) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (provider.canGoPrevious)
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isLoading || provider.isSaving 
                    ? null 
                    : () {
                        provider.previousStep();
                        _onStepChanged(provider.currentStep);
                      },
                child: const Text('Previous'),
              ),
            ),
          
          if (provider.canGoPrevious) const SizedBox(width: 16),
          
          // Next button
          Expanded(
            flex: provider.canGoPrevious ? 1 : 2,
            child: ElevatedButton(
              onPressed: _getNextButtonAction(provider),
              child: _getNextButtonChild(provider),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _getNextButtonAction(TestProvider provider) {
    if (provider.isLoading || provider.isSaving) return null;
    
    if (provider.currentStep == 0) {
      // Save basic info and go to next step
      return () async {
        await provider.saveBasicInfo();
        if (provider.errorMessage == null) {
          _onStepChanged(provider.currentStep);
        }
      };
    } else {
      // Just go to next step
      return provider.canGoNext ? () {
        provider.nextStep();
        _onStepChanged(provider.currentStep);
      } : null;
    }
  }

  Widget _getNextButtonChild(TestProvider provider) {
    if (provider.isLoading || provider.isSaving) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    return const Text('Next');
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<TestProvider>(context, listen: false).clearError();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}