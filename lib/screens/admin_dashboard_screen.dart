import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/food_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AppTheme.starYellow),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Super Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(currentUser?.name ?? 'System Admin', style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Row
            Row(
              children: [
                _buildStatBox('Total Sales', 'Rs. 450,200', Icons.payments, AppTheme.primaryGreen),
                const SizedBox(width: 12),
                _buildStatBox('Active Foods', '${FoodService.mockFoodItems.length}', Icons.fastfood, AppTheme.primaryOrange),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBox('Registered Users', '124 Users', Icons.group, Colors.indigo),
                const SizedBox(width: 12),
                _buildStatBox('MySQL System', 'CONNECTED', Icons.storage, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // Management Action Buttons
            const Text(
              'Database Management (MySQL)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.add, color: Colors.white)),
              title: const Text('Add New Food Item to MySQL', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Insert new dish, price, category into MySQL database'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Use XAMPP phpMyAdmin or Admin form to add items directly to MySQL!')),
                );
              },
            ),
            const SizedBox(height: 10),

            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(backgroundColor: AppTheme.primaryGreen, child: Icon(Icons.store, color: Colors.white)),
              title: const Text('Manage Restaurants & Drivers', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('View and edit partner accounts in MySQL'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
