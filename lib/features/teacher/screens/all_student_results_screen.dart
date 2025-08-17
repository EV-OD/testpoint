import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/models/test_model.dart';
import 'package:testpoint/models/test_session_model.dart';
import 'package:testpoint/models/user_model.dart';
import 'package:testpoint/services/group_service.dart';

class AllStudentResultsScreen extends StatefulWidget {
  final Test test;
  final List<TestSession> submissions;

  const AllStudentResultsScreen({
    super.key,
    required this.test,
    required this.submissions,
  });

  @override
  State<AllStudentResultsScreen> createState() => _AllStudentResultsScreenState();
}

class _AllStudentResultsScreenState extends State<AllStudentResultsScreen> {
  Map<String, User> _studentMap = {};
  bool _isLoadingUsers = true;
  String? _usersErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    try {
      setState(() {
        _isLoadingUsers = true;
        _usersErrorMessage = null;
      });

      final groupService = Provider.of<GroupService>(context, listen: false);
      final studentIds = widget.submissions.map((s) => s.studentId).toList();
      final users = await groupService.getUsers(studentIds);

      _studentMap = {for (var user in users) user.id: user};

      setState(() {
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
        _usersErrorMessage = 'Failed to load student details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.test.name} - All Results'),
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : _usersErrorMessage != null
              ? Center(child: Text(_usersErrorMessage!))
              : ListView.builder(
                  itemCount: widget.submissions.length,
                  itemBuilder: (context, index) {
                    final submission = widget.submissions[index];
                    final student = _studentMap[submission.studentId];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student?.name ?? 'Unknown Student',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student?.email ?? 'No Email',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Score: ${submission.finalScore}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Submitted: ${_formatDateTime(submission.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
