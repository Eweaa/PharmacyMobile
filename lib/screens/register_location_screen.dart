import 'package:flutter/material.dart';
import 'package:test_applicaiton_1/screens/login_screen.dart';
import 'package:test_applicaiton_1/styles/colors.dart';

class RegisterLocationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RegisterLocationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterLocationScreen> createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCity;
  String? _selectedDistrict;
  
  // Sample data for cities and districts
  final List<String> _cities = ['Cairo', 'Alexandria', 'Giza', 'Sharm El Sheikh'];
  final Map<String, List<String>> _districts = {
    'Cairo': ['Maadi', 'Nasr City', 'Heliopolis', 'Downtown'],
    'Alexandria': ['Montaza', 'Sidi Gaber', 'Smouha', 'Miami'],
    'Giza': ['Dokki', 'Mohandessin', '6th of October', 'Sheikh Zayed'],
    'Sharm El Sheikh': ['Naama Bay', 'Sharks Bay', 'Nabq Bay', 'Old Market'],
  };

  List<String> get _availableDistricts => 
      _selectedCity != null ? _districts[_selectedCity]! : [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      // appBar: AppBar(
      //   title: Text('Location Information'),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(  // Added Center widget here
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,  // Added for horizontal centering
                    children: [
                    SizedBox(height: 20),
                    Text(
                      'Your Location',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colorz.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: 1.0, // 100% progress (second page of two)
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colorz.blue,
                      ),
                    ),
                    SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                          _selectedDistrict = null; // Reset district when city changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colorz.blue, width: 3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _availableDistricts.map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: _selectedCity == null
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedDistrict = newValue;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a district';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Back', style: TextStyle(
                            color: Colorz.blue,
                          ),),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colorz.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Complete registration process
                              // Here you would typically call an API or save to a database
                              
                              // For now, just navigate to login
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration successful!')),
                              );
                              
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          child: Text('Register', style: TextStyle(
                            color: Colors.white,
                          ),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      )
    );
  }
}