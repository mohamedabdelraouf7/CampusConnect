import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  
  const ProfileScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _majorController = TextEditingController();
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    // In a real app, you would load user data from the app state
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@university.edu';
    _majorController.text = 'Computer Science';
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileForm(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _emailController.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _majorController,
            decoration: const InputDecoration(
              labelText: 'Major',
              prefixIcon: Icon(Icons.school),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save profile information
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // In your profile screen, find the dark mode switch and update it:
        
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle dark theme'),
          value: widget.appState.isDarkMode,
          onChanged: (value) {
            setState(() {
              widget.appState.isDarkMode = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Enable push notifications'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active),
          title: const Text('Notification Settings'),
          subtitle: const Text('Customize your reminders'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationSettingsScreen(appState: widget.appState),
              ),
            );
          },
        ),
        const AlertDialog(
          title: Text('Clear All Notifications'),
          content: Text('This will cancel all scheduled notifications. Are you sure?'),
          actions: [
            // ... your actions
          ],
        ),
        ListTile(
          title: const Text('Sync with Calendar'),
          subtitle: const Text('Sync events with device calendar'),
          trailing: const Icon(Icons.sync),
          onTap: () {
            // Sync with calendar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Syncing with calendar...')),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Show privacy policy
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Show terms of service
          },
        ),
        ListTile(
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
        ),
      ],
    );
  }
}