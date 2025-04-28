import 'package:flutter/material.dart';
import 'package:test_applicaiton_1/screens/Shared/login_screen.dart';
import 'package:test_applicaiton_1/styles/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';
import '../../../models/lookup.dart';
import '../../../models/base_response.dart';

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
  bool _isLoadingCities = true;
  bool _isLoadingDistricts = false;
  List<Lookup> _cities = [];
  List<Lookup> _districts = [];
  String _errorMessage = '';
  Lookup? _selectedCityObject;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoadingCities = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/Lookup/GetAll/EG_GOV'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final baseResponse = BaseResponse<Lookup>.fromJson(
          jsonData, 
          (lookupJson) => Lookup.fromJson(lookupJson)
        );
        
        setState(() {
          _cities = baseResponse.responseData;
          _isLoadingCities = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load cities: ${response.statusCode}';
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _fetchDistricts(String internalCode) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/Lookup/GetAll/$internalCode'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final baseResponse = BaseResponse<Lookup>.fromJson(
          jsonData, 
          (lookupJson) => Lookup.fromJson(lookupJson)
        );
        
        setState(() {
          _districts = baseResponse.responseData;
          _isLoadingDistricts = false;
        });
      } else {
        setState(() {
          _districts = [];
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      setState(() {
        _districts = [];
        _isLoadingDistricts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.currentLocale == 'en';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      value: 1.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colorz.blue,
                      ),
                    ),
                    SizedBox(height: 30),
                    if (_isLoadingCities)
                      CircularProgressIndicator()
                    else if (_errorMessage.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: _fetchCities,
                            child: Text('Try Again'),
                          ),
                        ],
                      )
                    else
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
                        items: _cities.map((Lookup city) {
                          return DropdownMenuItem<String>(
                            value: city.internalCode,
                            child: Text(isEnglish ? city.name : city.nameAr),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCity = newValue;
                              _selectedCityObject = _cities.firstWhere(
                                (city) => city.internalCode == newValue
                              );
                              _selectedDistrict = null;
                            });
                            // Fetch districts based on selected city's internal code
                            _fetchDistricts(newValue);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a city';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 16),
                    if (_isLoadingDistricts)
                      CircularProgressIndicator()
                    else
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
                        items: _districts.map((Lookup district) {
                          return DropdownMenuItem<String>(
                            value: district.internalCode,
                            child: Text(isEnglish ? district.name : district.nameAr),
                          );
                        }).toList(),
                        onChanged: _districts.isEmpty
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