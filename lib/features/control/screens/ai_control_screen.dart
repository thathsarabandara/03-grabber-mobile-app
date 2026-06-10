import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class AiControlScreen extends StatelessWidget {
  const AiControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 2),
                ),
                child: const Icon(LucideIcons.bot, size: 64, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 32),
            Text('Voice Command', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Talk to Robot',
              icon: LucideIcons.mic,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            Text('Text Command', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: '',
                    hint: 'e.g., "Pick the red object"',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text('AI Suggestions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSuggestionCard(context, LucideIcons.boxSelect, 'Sort Objects', 'Automatically identify and group similar items in the workspace.'),
            _buildSuggestionCard(context, LucideIcons.grab, 'Pick and Place', 'Move object to zone B using precision gripping.'),
            _buildSuggestionCard(context, LucideIcons.scan, 'Scan Workspace', 'Map the area for obstacles and valid target locations.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () {},
      ),
    );
  }
}
