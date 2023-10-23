import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  String _message = ''; // Mensaje para mostrar en la UI

  void _submit() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    BuildContext context = this.context;
    if (_isLogin) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Manejar inicio de sesión exitoso
        setState(() {
          _message = 'Login exitoso';
        });
        final User? user = _auth.currentUser;

        if (user != null) {
          if (user.email == "admin@megatech.cl") {
            // Navegar a la página "crud" si el correo es "admin@megatech.cl"
            Navigator.pushReplacementNamed(context, 'crud');
          } else {
            // Navegar a la página "home" para otros usuarios
            Navigator.pushReplacementNamed(context, 'home');
          }
        }
      } catch (e) {
        // Manejar errores de inicio de sesión
        setState(() {
          _message = 'Contraseña erronea o usuario no existe';
        });
        print('Login error: $e');
      }
    } else {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Manejar registro exitoso
        setState(() {
          _message = 'Registro exitoso';
        });
        // Puedes navegar a la página "home" o realizar cualquier otra acción necesaria
      } catch (e) {
        // Manejar errores de registro
        setState(() {
          _message = 'Error al registrar';
        });
        print('Registration error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
              Text(
                _message, // Muestra el mensaje en la UI
                style: TextStyle(
                  color:
                      _message.contains('exitoso') ? Colors.green : Colors.red,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Create an account'
                    : 'Already have an account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
