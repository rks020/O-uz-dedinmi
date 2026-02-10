import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Bildirimler'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Dil & Para Birimi'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Destek'),
          ),
        ],
      ),
    );
  }
}
