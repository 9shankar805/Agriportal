import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';
import '../../core/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    // TODO: Load from shared preferences
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(t.appearance, theme),
          const SizedBox(height: 12),
          _buildThemeTile(t, theme),
          const SizedBox(height: 8),
          _buildLanguageTile(t, theme),
          const SizedBox(height: 24),
          _buildSectionHeader(t.notifications, theme),
          const SizedBox(height: 12),
          _buildNotificationsTile(t, theme),
          const SizedBox(height: 24),
          _buildSectionHeader(t.legal, theme),
          const SizedBox(height: 12),
          _buildLegalTile(
            t.termsOfService,
            Icons.description,
            () => context.push(AppRoutes.terms),
            theme,
          ),
          const SizedBox(height: 8),
          _buildLegalTile(
            t.privacyPolicy,
            Icons.privacy_tip,
            () => context.push(AppRoutes.privacy),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.outline,
      ),
    );
  }

  Widget _buildThemeTile(AppLocalizations t, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          t.theme,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const CustomIconWidget(
          iconName: 'brightness_6',
          color: AppTheme.primary,
          size: 20,
        ),
        children: [
          RadioListTile<ThemeMode>(
            title: Text(
              t.light,
              style: GoogleFonts.plusJakartaSans(),
            ),
            value: ThemeMode.light,
            groupValue: ThemeController.instance.themeMode,
            onChanged: (value) {
              if (value != null) {
                ThemeController.instance.setThemeMode(value);
              }
            }),
          RadioListTile<ThemeMode>(
            title: Text(
              t.dark,
              style: GoogleFonts.plusJakartaSans(),
            ),
            value: ThemeMode.dark,
            groupValue: ThemeController.instance.themeMode,
            onChanged: (value) {
              if (value != null) {
                ThemeController.instance.setThemeMode(value);
              }
            }),
          RadioListTile<ThemeMode>(
            title: Text(
              t.system,
              style: GoogleFonts.plusJakartaSans(),
            ),
            value: ThemeMode.system,
            groupValue: ThemeController.instance.themeMode,
            onChanged: (value) {
              if (value != null) {
                ThemeController.instance.setThemeMode(value);
              }
            }),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations t, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          t.language,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const CustomIconWidget(
          iconName: 'language',
          color: AppTheme.primary,
          size: 20,
        ),
        children: [
          RadioListTile<String>(
            title: Text(
              t.english,
              style: GoogleFonts.plusJakartaSans(),
            ),
            value: 'en',
            groupValue: LanguageController.instance.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                LanguageController.instance.setLanguage(value);
              }
            }),
          RadioListTile<String>(
            title: Text(
              t.nepali,
              style: GoogleFonts.plusJakartaSans(),
            ),
            value: 'ne',
            groupValue: LanguageController.instance.locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                LanguageController.instance.setLanguage(value);
              }
            }),
        ],
      ),
    );
  }

  Widget _buildNotificationsTile(AppLocalizations t, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          t.pushNotifications,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const CustomIconWidget(
          iconName: 'notifications',
          color: AppTheme.primary,
          size: 20,
        ),
        trailing: Switch(
          value: _notificationsEnabled,
          onChanged: (value) async {
            setState(() => _notificationsEnabled = value);
            if (value) {
              await NotificationService.instance.init();
            } else {
              // TODO: Disable notifications
            }
          },
        ),
      ),
    );
  }

  Widget _buildLegalTile(String title, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Icon(
          icon,
          color: AppTheme.primary,
          size: 20,
        ),
        trailing: const CustomIconWidget(
          iconName: 'chevron_right',
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
