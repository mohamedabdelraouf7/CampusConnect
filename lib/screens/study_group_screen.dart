import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/study_group_card.dart';
import 'study_group_detail_screen.dart';
import 'study_group_form_screen.dart';

class StudyGroupScreen extends StatefulWidget {
  final AppState appState;
  
  const StudyGroupScreen({super.key, required this.appState});

  @override
  _StudyGroupScreenState createState() => _StudyGroupScreenState();
}

class _StudyGroupScreenState extends State<StudyGroupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          if (widget.appState.isInitialized)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyGroupFormScreen(appState: widget.appState),
                  ),
                );
                
                if (result == true) {
                  setState(() {});
                }
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'My Groups'),
          ],
        ),
      ),
      body: !widget.appState.isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading study groups...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _error = null);
                          widget.appState.initializeFirebase();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingStudyGroups(),
                    _buildMyStudyGroups(),
                  ],
                ),
    );
  }
  
  Widget _buildUpcomingStudyGroups() {
    final now = DateTime.now();
    final upcomingGroups = widget.appState.studyGroups
        .where((sg) => sg.dateTime.isAfter(now))
        .toList();
    
    // Sort by date
    upcomingGroups.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    if (upcomingGroups.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming study groups',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await widget.appState.firebaseService.initialize();
        } catch (e) {
          setState(() => _error = e.toString());
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingGroups.length,
        itemBuilder: (context, index) {
          final group = upcomingGroups[index];
          return StudyGroupCard(
            studyGroup: group,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyGroupDetailScreen(
                    appState: widget.appState,
                    studyGroup: group,
                  ),
                ),
              );
              
              if (result == true) {
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }
  
  Widget _buildMyStudyGroups() {
    // In a real app, you would filter by the current user's ID
    // For now, we'll just show all groups
    final myGroups = widget.appState.studyGroups.toList();
    
    if (myGroups.isEmpty) {
      return const Center(
        child: Text(
          'You haven\'t joined any study groups yet',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await widget.appState.firebaseService.initialize();
        } catch (e) {
          setState(() => _error = e.toString());
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myGroups.length,
        itemBuilder: (context, index) {
          final group = myGroups[index];
          return StudyGroupCard(
            studyGroup: group,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudyGroupDetailScreen(
                    appState: widget.appState,
                    studyGroup: group,
                  ),
                ),
              );
              
              if (result == true) {
                setState(() {});
              }
            },
          );
        },
      ),
    );
  }
}