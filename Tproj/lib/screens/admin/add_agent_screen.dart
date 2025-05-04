// File: lib/screens/admin/add_agent_screen.dart
import 'package:flutter/material.dart';
import '../../services/agent_service.dart';
import '../../widgets/admin_drawer.dart';

class AddAgentScreen extends StatefulWidget {
  const AddAgentScreen({Key? key}) : super(key: key);

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _agentService     = AgentService();

  final _firstNameCtrl    = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _ageCtrl          = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _phoneCtrl        = TextEditingController();

  String _jobType         = 'inspector';
  bool   _isSaving        = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _agentService.addAgent(
        firstName : _firstNameCtrl.text.trim(),
        lastName  : _lastNameCtrl.text.trim(),
        age       : int.parse(_ageCtrl.text.trim()),
        email     : _emailCtrl.text.trim(),
        phone     : _phoneCtrl.text.trim(),
        type      : _jobType,
      );

      if (mounted) {
        Navigator.pop(context, true);      // return success flag
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Agent'),
        backgroundColor: Colors.indigo[900],
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(_firstNameCtrl, 'First name'),
              const SizedBox(height: 16),
              _textField(_lastNameCtrl,  'Last name'),
              const SizedBox(height: 16),
              _textField(_ageCtrl,       'Age',          keyboard: TextInputType.number),
              const SizedBox(height: 16),
              _textField(_emailCtrl,     'Email',        keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _textField(_phoneCtrl,     'Phone number', keyboard: TextInputType.phone),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _jobType,
                items: const [
                  DropdownMenuItem(value: 'inspector', child: Text('Inspector')),
                  DropdownMenuItem(value: 'delivery' , child: Text('Delivery-man')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Job type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _jobType = v!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('SAVE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Please enter $label'.toLowerCase() : null,
    );
  }
}
