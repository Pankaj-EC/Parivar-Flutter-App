import 'package:flutter/material.dart';
import 'home_page.dart';
import 'team_page.dart';
import 'contact_page.dart';
import 'profile_page.dart';
import 'gallery_page.dart';
import 'colors.dart'; // Import the colors
import 'api_service.dart'; // Import the API service
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for storing JWT and userId

void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug label
      theme: ThemeData(
        primaryColor: primaryBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
        ),
      ),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  late ApiService _apiService;
  late SharedPreferences _prefs;
  bool _isLoggedIn = false;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ContactPage(),
    GalleryPage(),
    TeamPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString('token');
    String? userId = _prefs.getString('userId');

    if (token != null && userId != null) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLoginDialog());
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login'),
          content: LoginForm(
            apiService: _apiService,
            prefs: _prefs,
            onLoginSuccess: () {
              setState(() {
                _isLoggedIn = true;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn ? _pages[_selectedIndex] : Container(),
      bottomNavigationBar: _isLoggedIn
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Contact',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.image),
                  label: 'Gallery',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.contact_mail),
                  label: 'Team',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: primaryOrange,
              unselectedItemColor: primaryDarkBlue,
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}

class LoginForm extends StatefulWidget {
  final ApiService apiService;
  final SharedPreferences prefs;
  final VoidCallback onLoginSuccess;

  LoginForm({required this.apiService, required this.prefs, required this.onLoginSuccess});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await widget.apiService.login(
          _userIdController.text,
          _passwordController.text,
        );

        if (response['status']['statusCode'] == 1111) {
          await widget.prefs.setString('token', response['data']['token']);
          await widget.prefs.setString('userId', response['data']['userId']);
          widget.onLoginSuccess();
        } else {
          _showError(response['status']['statusMessage']);
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your user ID';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
