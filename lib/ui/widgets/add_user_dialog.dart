import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'glass_card.dart';

class AddUserDialog extends StatefulWidget {
  final String role; // 'motorist', 'provider', or 'repair_shop'
  
  const AddUserDialog({super.key, required this.role});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _plateController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _createUser() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'admin_create_user',
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': widget.role,
          if (widget.role == 'repair_shop') 'company_name': _companyController.text.trim(),
          if (widget.role == 'provider') 'vehicle_plate': _plateController.text.trim(),
        },
      );

      if (response.status == 200) {
        if (mounted) Navigator.pop(context, true); // true = success
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Motorist';
    if (widget.role == 'provider') title = 'Driver';
    if (widget.role == 'repair_shop') title = 'Repair Shop';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New $title', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              _buildField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              _buildField(_emailController, 'Email Address', Icons.email),
              const SizedBox(height: 16),
              _buildField(_passwordController, 'Password (Min 6 chars)', Icons.lock, obscure: true),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Phone Number', Icons.phone),
              
              if (widget.role == 'repair_shop') ...[
                const SizedBox(height: 16),
                _buildField(_companyController, 'Company Name', Icons.business),
              ],
              if (widget.role == 'provider') ...[
                const SizedBox(height: 16),
                _buildField(_plateController, 'Vehicle Plate', Icons.directions_car),
              ],
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createUser,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), foregroundColor: Colors.black),
                    child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text('Create User'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
