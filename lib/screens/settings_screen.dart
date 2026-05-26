import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vlc_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VlcProvider>(context, listen: false);
    _ipController = TextEditingController(text: provider.ip);
    _portController = TextEditingController(text: provider.port?.toString() ?? '8080');
    _passwordController = TextEditingController(text: provider.password);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VLC Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: 'IP Address'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<VlcProvider>().updateSettings(
                      _ipController.text,
                      int.parse(_portController.text),
                      _passwordController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save & Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
