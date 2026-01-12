import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider to manage authentication state including guest mode.
///
/// This allows users to preview the dashboard without signing in,
/// while restricting actions like adding logs and managing cars.
class AppAuthProvider extends ChangeNotifier {
  bool _isGuestMode = false;

  /// Whether the user is browsing as a guest (not signed in).
  bool get isGuestMode => _isGuestMode;

  /// Whether the user is fully authenticated via Firebase.
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  /// Whether the user can access the dashboard (either authenticated or guest).
  bool get canAccessDashboard => isAuthenticated || _isGuestMode;

  /// Enter guest mode to preview the app without signing in.
  void enterGuestMode() {
    _isGuestMode = true;
    notifyListeners();
  }

  /// Exit guest mode (typically when user signs in or explicitly logs out).
  void exitGuestMode() {
    _isGuestMode = false;
    notifyListeners();
  }

  /// Check if an action requires authentication and show login prompt if needed.
  ///
  /// Returns `true` if the user is authenticated and can proceed.
  /// Returns `false` if the user is a guest (shows login dialog).
  Future<bool> requireAuth(
    BuildContext context, {
    String? actionDescription,
  }) async {
    if (isAuthenticated) {
      return true;
    }

    // Show login required dialog for guests
    final shouldLogin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Login Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          actionDescription ?? 'Sign in to add fuel logs and manage your cars.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldLogin == true && context.mounted) {
      // Exit guest mode and navigate to login
      exitGuestMode();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }

    return false;
  }
}
