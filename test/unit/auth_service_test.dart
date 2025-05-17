import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../test_helpers.dart';

@GenerateMocks([FirebaseAuth, User])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late MockUser mockUser;

  setUpAll(() async {
    // await setupFirebaseForTesting(); // REMOVED
  });

  setUp(() async {
    await resetFirebaseState();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authService = FirebaseAuthService.withAuth(mockAuth);
  });

  group('Authentication Service Tests', () {
    test('Get current user returns user when signed in', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.uid).thenReturn('test_uid');

      // Act
      final user = authService.currentUser;

      // Assert
      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      expect(user?.uid, 'test_uid');
    });

    test('Get current user returns null when signed out', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final user = authService.currentUser;

      // Assert
      expect(user, isNull);
    });

    test('Auth state changes stream emits user when signed in', () async {
      // Arrange
      when(mockAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(mockUser),
      );
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.uid).thenReturn('test_uid');

      // Act
      final stream = authService.authStateChanges;
      final user = await stream.first;

      // Assert
      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      expect(user?.uid, 'test_uid');
    });

    test('Auth state changes stream emits null when signed out', () async {
      // Arrange
      when(mockAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      // Act
      final stream = authService.authStateChanges;
      final user = await stream.first;

      // Assert
      expect(user, isNull);
    });
  });
} 