// import 'package:flutter/widgets.dart';

// class AuthEntity extends StatelessWidget {
//   const AuthEntity({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// import 'package:http/http.dart' as http;

final class AuthEntity {
  final String email;
  final String password;

  const AuthEntity({
    required this.email,
    required this.password,
  });
}
