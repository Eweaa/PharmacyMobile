import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:test_applicaiton_1/layouts/admin_layout.dart';
import 'package:test_applicaiton_1/screens/Admin_Screens/Ads_Management/create_ad_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/advertisement_data.dart';
import '../../../models/base_response.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';
import 'package:test_applicaiton_1/providers/language_provider.dart';
import '../../../utils/ad_card_utils.dart';

class AdsManagementScreen extends StatefulWidget {
  const AdsManagementScreen({super.key});

  @override
  State<AdsManagementScreen> createState() => _AdsManagementScreenState();
}

class _AdsManagementScreenState extends State<AdsManagementScreen> {
  bool _isLoading = true;
  List<AdvertisementData> _advertisements = [];
  String _errorMessage = '';
  bool _isGridView = true; // Add this state variable to track the current view mode

  @override
  void initState() {
    super.initState();
    _fetchAdvertisements();
  }

  Future<void> _fetchAdvertisements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/GetAllAdvertisements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final baseResponse = BaseResponse<AdvertisementData>.fromJson(
          jsonData, 
          (adJson) => AdvertisementData.fromJson(adJson)
        );
        
        setState(() {
          _advertisements = baseResponse.responseData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load advertisements: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLocale.languageCode;

    return AdminLayout(
      title: AppLocalizations.translate('ads_List', lang),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add view toggle button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [_isGridView, !_isGridView],
                      onPressed: (index) {
                        setState(() {
                          _isGridView = index == 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      color: Colors.grey[600],
                      constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                      children: const [
                        Icon(Icons.grid_view, size: 20),
                        Icon(Icons.view_list, size: 20),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage.isNotEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchAdvertisements,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                else if (_advertisements.isEmpty)
                  const Center(
                    child: Text('No advertisements found'),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchAdvertisements,
                      child: _isGridView 
                        ? _buildGridView() 
                        : _buildListView(),
                    ),
                  ),
              ],
            ),
            // Add floating action button in the bottom corner
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to add advertisement screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAdScreen(),
                    ),
                  ).then((_) {
                    // Refresh the list when returning from create screen
                    _fetchAdvertisements();
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add these new methods for grid and list views
  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _advertisements.length,
      itemBuilder: (context, index) {
        final ad = _advertisements[index];
        return _buildAdCard(ad);
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _advertisements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ad = _advertisements[index];
        return _buildListItem(ad);
      },
    );
  }

  Widget _buildListItem(AdvertisementData ad) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    // Transform the image path to a proper URL (same as in _buildAdCard)
    String imageUrl = '';
    if (ad.adImages.isNotEmpty) {
      final String rawPath = ad.adImages.first;
      if (rawPath.contains('images')) {
        final List<String> parts = rawPath.split('images');
        final String filename = parts.last;
        final String cleanFilename = filename.startsWith('\\') || filename.startsWith('/') 
            ? filename.substring(1) 
            : filename;
        imageUrl = 'https://ph-identity.elhamylabs.com/images/$cleanFilename';
      }
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 100,
                child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 30),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 30),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ad.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AdCardUtils.getStatusText(ad.statusId)
                  ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 2),
                        Text(
                          '${ad.fees}',
                          style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          dateFormat.format(ad.startDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 16),
                        AdCardUtils.showAcceptBtn(ad.statusId, ad.id, _changeAdvertisementStatus),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          constraints: const BoxConstraints(),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteConfirmation(ad);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
         ),
        ),
      );
  }
  
  Widget _buildAdCard(AdvertisementData ad) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    String imageUrl = '';
    if (ad.adImages.isNotEmpty) {
      final String rawPath = ad.adImages.first;
      if (rawPath.contains('images')) {
        final List<String> parts = rawPath.split('images');
        final String filename = parts.last;
        
        final String cleanFilename = filename.startsWith('\\') || filename.startsWith('/') 
            ? filename.substring(1) 
            : filename;
        imageUrl = 'https://ph-identity.elhamylabs.com/images/$cleanFilename';
      }
    }
    
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,  stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(Icons.image, size: 50),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AdCardUtils.getStatusText(ad.statusId),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 2),
                      Text(
                        '${ad.fees}',
                        style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 4),
                  // Text(
                  //   'Start: ${dateFormat.format(ad.startDate)}',
                  //   style: const TextStyle(fontSize: 12),
                  // ),
                  Text(
                    'End: ${dateFormat.format(ad.endDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  // Only show phone number if it exists in the model
                  // if (ad.createdBy.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4.0),
                  //     child: Row(
                  //       children: [
                  //         const Icon(Icons.person, size: 14),
                  //         const SizedBox(width: 2),
                  //         Text(
                  //           'By: ${ad.createdBy}',
                  //           style: const TextStyle(fontSize: 12),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AdCardUtils.showAcceptBtn(ad.statusId, ad.id, _changeAdvertisementStatus),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () {
                          _showDeleteConfirmation(ad);
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ))],
      ),
    );
  }

  Future<void> _deleteAdvertisement(int adId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      final response = await http.delete(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/DeleteAdvertisement/$adId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _advertisements.removeWhere((ad) => ad.id == adId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advertisement deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete advertisement: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteConfirmation(AdvertisementData ad) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = languageProvider.currentLocale.languageCode;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.translate('delete_ad', lang)),
          content: Text(AppLocalizations.translate('delete_ad_message', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.translate('cancel', lang)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAdvertisement(ad.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.translate('delete', lang)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeAdvertisementStatus(int adId, int statusId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/ChangeAdvertisementStatus/$adId/$statusId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update the ad in the list
        setState(() {
          final index = _advertisements.indexWhere((ad) => ad.id == adId);
          if (index != -1) {
            _advertisements[index] = _advertisements[index].copyWith(statusId: statusId);
          }
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Advertisement status updated successfully')),
          );
        }
        
        // Refresh the list
        _fetchAdvertisements();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update advertisement status: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
