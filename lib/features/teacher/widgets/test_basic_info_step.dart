import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/test_provider.dart';
import 'package:testpoint/models/group_model.dart';

class TestBasicInfoStep extends StatefulWidget {
  const TestBasicInfoStep({super.key});

  @override
  State<TestBasicInfoStep> createState() => _TestBasicInfoStepState();
}

class _TestBasicInfoStepState extends State<TestBasicInfoStep> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: provider.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Test Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the basic information for your test',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Test Name Field
                _buildTestNameField(provider),
                const SizedBox(height: 16),

                // Group Selection Field
                _buildGroupSelectionField(provider),
                const SizedBox(height: 16),

                // Time Limit Field
                _buildTimeLimitField(provider),
                const SizedBox(height: 16),

                // Date and Time Fields
                Row(
                  children: [
                    Expanded(child: _buildDateField(provider)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField(provider)),
                  ],
                ),
                const SizedBox(height: 24),

                // Instructions Card
                _buildInstructionsCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestNameField(TestProvider provider) {
    return TextFormField(
      controller: provider.nameController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Test Name *',
        hintText: 'Enter test name (e.g., Mathematics Mid-term)',
        prefixIcon: const Icon(Icons.quiz),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Test name is required';
        }
        if (value.trim().length < 3) {
          return 'Test name must be at least 3 characters';
        }
        if (value.trim().length > 100) {
          return 'Test name cannot exceed 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildGroupSelectionField(TestProvider provider) {
    // Ensure the selected value exists in the available groups
    final selectedId = provider.selectedGroupId;
    final validSelectedId = provider.availableGroups.any((group) => group.id == selectedId) 
        ? selectedId 
        : null;
    
    return DropdownButtonFormField<String>(
      value: validSelectedId,
      decoration: InputDecoration(
        labelText: 'Select Group *',
        hintText: 'Choose the group for this test',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        prefixIcon: const Icon(Icons.group),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      items: provider.availableGroups.map((Group group) {
        return DropdownMenuItem<String>(
          value: group.id,
          child: Text(
            '${group.name} (${group.memberCount} members)',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          provider.selectGroup(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a group';
        }
        return null;
      },
    );
  }

  Widget _buildTimeLimitField(TestProvider provider) {
    return TextFormField(
      controller: provider.timeLimitController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Time Limit (minutes) *',
        hintText: 'Enter time limit (5-300 minutes)',
        prefixIcon: const Icon(Icons.timer),
        suffixText: 'min',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Time limit is required';
        }
        final timeLimit = int.tryParse(value);
        if (timeLimit == null) {
          return 'Please enter a valid number';
        }
        if (timeLimit < 5) {
          return 'Time limit must be at least 5 minutes';
        }
        if (timeLimit > 300) {
          return 'Time limit cannot exceed 300 minutes';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TestProvider provider) {
    return TextFormField(
      controller: provider.dateController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Test Date *',
        hintText: 'DD/MM/YYYY',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, provider),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Test date is required';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField(TestProvider provider) {
    return TextFormField(
      controller: provider.timeController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Test Time *',
        hintText: 'HH:MM',
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      readOnly: true,
      onTap: () => _selectTime(context, provider),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Test time is required';
        }
        return null;
      },
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('Choose a descriptive name for your test'),
            _buildInstructionItem('Select the group of students who will take this test'),
            _buildInstructionItem('Set an appropriate time limit (5-300 minutes)'),
            _buildInstructionItem('Schedule the test for a future date and time'),
            _buildInstructionItem('You can edit test details until it\'s published'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TestProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.dateController.text = 
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _selectTime(BuildContext context, TestProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.timeController.text = 
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}