import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/routes/app_routes.dart';
import 'package:zpluspasswordmanager/core/widgets/loading_overlay_widget.dart';
import 'package:zpluspasswordmanager/features/auth/controllers/auth_controller.dart';
import 'package:zpluspasswordmanager/features/password_manager/controllers/secure_password_manager_controller.dart';
import 'package:zpluspasswordmanager/features/password_manager/models/password_model.dart';

/// HomePage is the main screen of the password manager application.
/// It displays a list of stored passwords and provides navigation to other features.
/// The page includes:
/// - A drawer for navigation and settings
/// - A list of stored passwords
/// - A floating action button to add new passwords
class HomePage extends StatelessWidget {
  final _passwordController = Get.find<SecurePasswordManagerController>();
  final _authController = Get.find<AuthController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWidget(
      child: Scaffold(
        // App bar with title
        appBar: AppBar(
          title: const Text('Password Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(AppRoutes.addPassword),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
          ],
        ),
        // Navigation drawer
        drawer: Drawer(
          child: ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                // Home navigation item
                ListTile(
                  title: const Text('Home'),
                  onTap: () => Get.offAllNamed(AppRoutes.home),
                ),
                // Settings navigation item
                ListTile(
                  title: const Text('Settings'),
                  onTap: () => Get.toNamed(AppRoutes.settings),
                ),
                // Logout item with authentication handling
                ListTile(
                  title: const Text('Log Out'),
                  onTap: _handleLogout,
                ),
              ],
            ).toList(),
          ),
        ),
        // Main content area
        body: Obx(() {
          final passwords = _passwordController.passwords;

          if (passwords.isEmpty) {
            return const Center(
              child: Text('Basic Home Screen. yet to be developed'),
            );
          }

          return ListView.builder(
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final password = passwords[index];
              return ListTile(
                title: Text(password.website),
                subtitle: Text(password.username),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _handleDelete(password),
                ),
                onTap: () => _handleViewPassword(password),
              );
            },
          );
        }),
        // Floating action button to add new passwords
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.addPassword),
          backgroundColor: Colors.grey.shade700,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _authController.signOut();
  }

  Future<void> _handleDelete(Password password) async {
    await _passwordController.deletePassword(password);
  }

  void _handleViewPassword(Password password) {
    Get.toNamed(AppRoutes.viewPassword, arguments: password);
  }
}
