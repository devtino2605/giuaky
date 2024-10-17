import 'package:flutter/material.dart';
import '../../service/auth_service.dart';

class Index extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("INDEX"),
        actions: [
          IconButton(
              onPressed: () {
                authService.logout(context);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text("INDEX"),
      ),
    );
  }
}
