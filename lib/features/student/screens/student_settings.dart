import 'package:flutter/material.dart';

class StudentSettings extends StatelessWidget {
  const StudentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSection(
          title: 'Appearance',
          items: [
            _SettingsItem(
              icon: Icons.brightness_6_outlined,
              title: 'Theme',
              subtitle: 'System',
              onTap: () {
                // TODO: Implement theme settings
              },
            ),
            _SettingsItem(
              icon: Icons.text_fields,
              title: 'Text Size',
              subtitle: 'Normal',
              onTap: () {
                // TODO: Implement text size settings
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Notifications',
          items: [
            _SettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Test Reminders',
              subtitle: 'On',
              onTap: () {
                // TODO: Implement notification settings
              },
            ),
            _SettingsItem(
              icon: Icons.timer_outlined,
              title: 'Reminder Time',
              subtitle: '1 hour before',
              onTap: () {
                // TODO: Implement reminder time settings
              },
            ),
            _SettingsItem(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Off',
              onTap: () {
                // TODO: Implement email settings
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Account',
          items: [
            _SettingsItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                // TODO: Implement password change
              },
            ),
            _SettingsItem(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Off',
              onTap: () {
                // TODO: Implement 2FA settings
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Test Preferences',
          items: [
            _SettingsItem(
              icon: Icons.speed,
              title: 'Auto Submit',
              subtitle: 'When time expires',
              onTap: () {
                // TODO: Implement auto submit settings
              },
            ),
            _SettingsItem(
              icon: Icons.timer,
              title: 'Show Time Remaining',
              subtitle: 'Always',
              onTap: () {
                // TODO: Implement timer visibility settings
              },
            ),
          ],
        ),
        _buildSection(
          title: 'About',
          items: [
            _SettingsItem(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _SettingsItem(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () {
                // TODO: Implement help screen
              },
            ),
            _SettingsItem(
              icon: Icons.policy,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ...items,
        const Divider(),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
