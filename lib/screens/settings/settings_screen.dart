import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, SettingsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(context),
          const SizedBox(height: 32),
          _buildAboutSection(context),
          const SizedBox(height: 32),
          _buildApiKeySection(context, viewModel),
          const SizedBox(height: 32), // Add spacing before the info links
          _buildInfoLinksSection(context), // Add the separated info links section
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/full_RRA.png',
            width: 250,
            fit: BoxFit.contain,
          )
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ReadReveal AI is a mobile app that uses Google\'s Gemini API to '
          'analyze and explain text in images. It\'s perfect for quickly understanding '
          'complex text from books, documents, or signs.',
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
      ],
    );
  }

  Widget _buildInfoLinksSection(BuildContext context) {
    // Separated GitHub and Privacy Policy links
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.code),
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          onTap: () {
            // Open GitHub link using url_launcher
            launchUrl(Uri.parse('https://github.com/nitishv2017/ReadRevealAi'));
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () {
            // Open privacy policy - would use url_launcher in a real app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy policy would open here')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildApiKeySection(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gemini API Key',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your Gemini API key to use text recognition features.',
        ),
        const SizedBox(height: 16),
        // Collapsible section for steps to get API key
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text(
            'How to get your API Key',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1. Go to the Google AI Studio dashboard.'),
                  SizedBox(height: 4),
                  Text('2. Create a new API key.'),
                  SizedBox(height: 4),
                  Text('3. Copy the generated key.'),
                  SizedBox(height: 4),
                  Text('4. Paste it into the field below.'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red[700],
                  onPressed: viewModel.clearError,
                ),
              ],
            ),
          ),
        TextFormField(
          initialValue: viewModel.apiKey,
          onChanged: viewModel.updateApiKey,
          decoration: InputDecoration(
            labelText: 'API Key',
            hintText: viewModel.hasApiKey
                ? '••••••••••••••••••••'
                : 'Enter your Gemini API key',
            border: const OutlineInputBorder(),
            suffixIcon: viewModel.apiKey.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => viewModel.updateApiKey(''),
                  )
                : null,
          ),
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.apiKey.isEmpty ? null : viewModel.saveApiKey,
            child: Text(viewModel.hasApiKey ? 'Update API Key' : 'Save API Key'),
          ),
        ),
        if (viewModel.hasApiKey) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: viewModel.clearApiKey,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clear API Key'),
            ),
          ),
        ],
      ],
    );
  }
}