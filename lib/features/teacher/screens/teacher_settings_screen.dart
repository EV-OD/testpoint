import 'package:flutter/material.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSection(
          title: 'Appearance',
          items: [
            _SettingsItem(
              icon: Icons.brightness_6,
              title: 'Theme',
              subtitle: 'Light',
              onTap: () {
                // TODO: Implement theme switching
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Notifications',
          items: [
            _SettingsItem(
              icon: Icons.notifications,
              title: 'Test Submissions',
              subtitle: 'Enabled',
              onTap: () {
                // TODO: Implement notification settings
              },
            ),
            _SettingsItem(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Disabled',
              onTap: () {
                // TODO: Implement email notification settings
              },
            ),
          ],
        ),
        _buildSection(
          title: 'Security',
          items: [
            _SettingsItem(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                // TODO: Implement password change
              },
            ),
            _SettingsItem(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Disabled',
              onTap: () {
                // TODO: Implement 2FA
              },
            ),
          ],
        ),
        _buildSection(
          title: 'About',
          items: [
            _SettingsItem(
              icon: Icons.info,
              title: 'Version',
              subtitle: '1.0.0',
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
