import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';
import '../../../models/lookup.dart';
import '../../../models/base_response.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:http_parser/http_parser.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({Key? key}) : super(key: key);

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController(); // Added missing controller
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  // Change these from String? to int?
  int? _selectedCity;
  int? _selectedAdType;
  int? _selectedArea;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Added for API integration
  bool _isLoading = false; // Added missing loading state variable
  bool _isLoadingCities = true;
  bool _isLoadingAreas = false;
  List<Lookup> _cities = [];
  List<Lookup> _areas = [];
  List<Lookup> _adTypes = [];
  String _errorMessage = '';
  Lookup? _selectedCityObject;

  // Add these variables to the _CreateAdScreenState class
  bool _isLoadingAdTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchAdTypes(); // Add this line to fetch ad types
  }

  

  // Add this method to fetch ad types from API
  Future<void> _fetchAdTypes() async {
    setState(() {
      _isLoadingAdTypes = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/Lookup/GetAll/AD_TYPE'),
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
          _adTypes = baseResponse.responseData;
          _isLoadingAdTypes = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load ad types: ${response.statusCode}';
          _isLoadingAdTypes = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingAdTypes = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); // Added missing dispose
    _notesController.dispose();
    _descriptionController.dispose();
    _feesController.dispose();
    _phoneNumberController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Added method to fetch cities from API
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

  // Added method to fetch areas based on selected city
  Future<void> _fetchAreas(String internalCode) async {
    setState(() {
      _isLoadingAreas = true;
      _areas = [];
      _selectedArea = null;
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
          _areas = baseResponse.responseData;
          _isLoadingAreas = false;
        });
      } else {
        setState(() {
          _areas = [];
          _isLoadingAreas = false;
        });
      }
    } catch (e) {
      setState(() {
        _areas = [];
        _isLoadingAreas = false;
      });
    }
  }

  // Updated method to handle form submission using FormData
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
  
    setState(() {
      _isLoading = true;
    });
  
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();
  
      // Create a multipart request
      final uri = Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/CreateAdvertisement');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['note'] = _notesController.text;
      request.fields['fees'] = _feesController.text;
      request.fields['amount'] = _amountController.text;
      request.fields['phoneNumber'] = _phoneNumberController.text;
      request.fields['startDate'] = _dateController.text;
      request.fields['city'] = _selectedCity.toString();
      request.fields['AdTargetUserTypes'] = '1';
      if (_selectedArea != null) {
        request.fields['area'] = _selectedArea.toString();
      }
      request.fields['adType'] = _selectedAdType.toString();
      request.fields['status'] = '113';
      
      // Add image files if any - FIXED to avoid _namespace error
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final bytes = file;
        
        final multipartFile = http.MultipartFile(
          'adImages', // Field name for the file
          bytes.readAsBytes().asStream(),
          bytes.lengthSync(),
          filename: 'image_$i.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        
        request.files.add(multipartFile);
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
  
      setState(() {
        _isLoading = false;
      });
  
      if (response.statusCode == 200 || response.statusCode == 201)
      {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advertisement created successfully')),
        );
        Navigator.pop(context); // Return to previous screen
      }
      else
      {
        // Error
        String errorMessage;
        try
        {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'Failed to create advertisement';
        }
        catch (e)
        {
          errorMessage = 'Failed to create advertisement: ${response.statusCode}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.currentLocale.languageCode == 'en';
    final lang = languageProvider.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate('create_Ad', lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Each field in its own row
              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _descriptionController,
                label: AppLocalizations.translate('Description', lang),
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _feesController,
                label: 'Fees',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _phoneNumberController,
                label: AppLocalizations.translate('phoneNumber', lang),
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              _buildDateField(
                controller: _dateController,
                label: AppLocalizations.translate('startDate', lang),
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _amountController,
                label: 'Amount',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // City and Area in the same row
              _buildTwoColumnRow(
                leftWidget: _isLoadingCities
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCityDropdown(
                      label: AppLocalizations.translate('city', lang),
                      isEnglish: isEnglish,
                      isRequired: true,
                    ),
                rightWidget: _isLoadingAreas
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAreaDropdown(
                      label: AppLocalizations.translate('area', lang),
                      isEnglish: isEnglish,
                      isRequired: true,
                    ),
              ),
              const SizedBox(height: 16),
              
              _isLoadingAdTypes
                ? const Center(child: CircularProgressIndicator())
                : _buildAdTypeDropdown(
                    label: 'Ad Type',
                    isEnglish: isEnglish,
                    isRequired: true,
                  ),
              const SizedBox(height: 16),
              
              _buildImagePicker(
                label: 'Ad Images',
                isRequired: true,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Ad', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdTypeDropdown({
    required String label,
    required bool isEnglish,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<int>(
      value: _selectedAdType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(),
      ),
      hint: Text(isEnglish ? 'Select Ad Type' : 'نوع الإعلان'),
      items: _adTypes.map((Lookup adType) {
        return DropdownMenuItem<int>(
          value: adType.id, // Use id instead of internalCode
          child: Text(isEnglish ? adType.name : adType.nameAr),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedAdType = newValue;
          });
        }
      },
      validator: isRequired
        ? (value) {
            if (value == null) {
              return 'Please select $label';
            }
            return null;
          }
        : null,
    );
  }

  Widget _buildCityDropdown({
    required String label,
    required bool isEnglish,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<int>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(),
      ),
      hint: Text(isEnglish ? 'Select City' : 'المدينة'),
      items: _cities.map((Lookup city) {
        return DropdownMenuItem<int>(
          value: city.id, // Use id instead of internalCode
          child: Text(isEnglish ? city.name : city.nameAr),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCity = newValue;
            _selectedCityObject = _cities.firstWhere(
              (city) => city.id == newValue // Compare by id instead of internalCode
            );
            _selectedArea = null;
          });
          // Fetch areas based on selected city's internal code
          // We still need to use internalCode for the API call
          final selectedCity = _cities.firstWhere((city) => city.id == newValue);
          _fetchAreas(selectedCity.internalCode);
        }
      },
      validator: isRequired
        ? (value) {
            if (value == null) {
              return 'Please select $label';
            }
            return null;
          }
        : null,
    );
  }

  Widget _buildAreaDropdown({
    required String label,
    required bool isEnglish,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<int>(
      value: _selectedArea,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(),
      ),
      hint: Text(isEnglish ? 'Select Area' : 'المنطقة'),
      items: _areas.map((Lookup area) {
        return DropdownMenuItem<int>(
          value: area.id, // Use id instead of internalCode
          child: Text(isEnglish ? area.name : area.nameAr),
        );
      }).toList(),
      onChanged: _areas.isEmpty
        ? null
        : (int? newValue) {
            setState(() {
              _selectedArea = newValue;
            });
          },
      validator: isRequired
        ? (value) {
            if (value == null) {
              return 'Please select $label';
            }
            return null;
          }
        : null,
    );
  }

  Widget _buildTwoColumnRow({
    required Widget leftWidget,
    required Widget rightWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leftWidget),
        const SizedBox(width: 16),
        Expanded(child: rightWidget),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.text.isEmpty ? 'Select Date' : controller.text,
              style: TextStyle(
                color: controller.text.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(),
      ),
      value: value,
      hint: Text(hintText),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildImagePicker({
    required String label,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _selectedImages.isEmpty
              ? Center(
                  child: TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Images'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  _selectedImages[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
 
  

