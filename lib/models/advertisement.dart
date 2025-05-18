class AdImage {
  final int id;
  final String imageUrl;
  
  AdImage({
    required this.id,
    required this.imageUrl,
  });
  
  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

enum AdStatus {
  active,
  inactive,
  pending,
  rejected
}

enum AdType {
  standard,
  featured,
  premium
}

class AdTargetUser {
  final int id;
  final String userType;
  
  AdTargetUser({
    required this.id,
    required this.userType,
  });
  
  factory AdTargetUser.fromJson(Map<String, dynamic> json) {
    return AdTargetUser(
      id: json['id'] ?? 0,
      userType: json['userType'] ?? '',
    );
  }
}

class Advertisement {
  final int id;
  final String title;
  final String description;
  final List<AdImage> adImages;
  final String? note;
  final double fees;
  final double? amount;
  final DateTime startDate;
  final DateTime endDate;
  final String phoneNumber;
  final int cityId;
  final int areaId;
  final AdStatus status;
  final AdType adType;
  final List<AdTargetUser> adTargetUserTypes;

  Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.adImages,
    this.note,
    required this.fees,
    this.amount,
    required this.startDate,
    required this.endDate,
    required this.phoneNumber,
    required this.cityId,
    required this.areaId,
    required this.status,
    required this.adType,
    required this.adTargetUserTypes,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      adImages: json['adImages'] != null
          ? (json['adImages'] as List).map((img) => AdImage.fromJson(img)).toList()
          : [],
      note: json['note'],
      fees: (json['fees'] ?? 0).toDouble(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      phoneNumber: json['phoneNumber'] ?? '',
      cityId: json['cityId'] ?? 0,
      areaId: json['areaId'] ?? 0,
      status: _parseAdStatus(json['status']),
      adType: _parseAdType(json['adType']),
      adTargetUserTypes: json['adTargetUserTypes'] != null
          ? (json['adTargetUserTypes'] as List).map((user) => AdTargetUser.fromJson(user)).toList()
          : [],
    );
  }
  
  static AdStatus _parseAdStatus(dynamic status) {
    if (status is int) {
      return AdStatus.values[status];
    } else if (status is String) {
      try {
        return AdStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
        );
      } catch (_) {
        return AdStatus.inactive;
      }
    }
    return AdStatus.inactive;
  }
  
  static AdType _parseAdType(dynamic type) {
    if (type is int) {
      return AdType.values[type];
    } else if (type is String) {
      try {
        return AdType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
        );
      } catch (_) {
        return AdType.standard;
      }
    }
    return AdType.standard;
  }
  
  bool get isActive => status == AdStatus.active;
}