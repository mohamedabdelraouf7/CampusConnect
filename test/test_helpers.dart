import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseApp])
import 'test_helpers.mocks.dart';

// Global mock Firebase app instance
late MockFirebaseApp mockFirebaseApp;

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set up test configuration
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with test configuration
  // This will use the test configuration from firebase_options.dart
  // but won't actually try to connect to Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project-id',
      storageBucket: 'test-storage-bucket',
    ),
  );
}

// Helper function to reset Firebase state between tests
Future<void> resetFirebaseState() async {
  // No-op for now since we're not actually connecting to Firebase
} 