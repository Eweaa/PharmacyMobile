import 'dart:convert';

class AdvertisementData {
  final int id;
  final String? adType;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? status;
  final int statusId;
  final double fees;
  final double? amount;
  final List<String> adImages;
  final String createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdvertisementData({
    required this.id,
    this.adType,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.status,
    required this.statusId,
    required this.fees,
    this.amount,
    required this.adImages,
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdvertisementData.fromJson(Map<String, dynamic> json) {
    return AdvertisementData(
      id: json['id'] ?? 0,
      adType: json['adType'],
      description: json['description'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime(1),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime(1),
      status: json['status'],
      statusId: json['statusId'] ?? 0,
      fees: (json['fees'] ?? 0).toDouble(),
      amount: json['amount'] != null ? (json['amount']).toDouble() : null,
      adImages: (json['adImages'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime(1),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adType': adType,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'statusId': statusId,
      'fees': fees,
      'amount': amount,
      'adImages': adImages,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  AdvertisementData copyWith({
    int? id,
    String? adType,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? statusId,
    double? fees,
    double? amount,
    List<String>? adImages,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdvertisementData(
      id: id ?? this.id,
      adType: adType ?? this.adType,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      statusId: statusId ?? this.statusId,
      fees: fees ?? this.fees,
      amount: amount ?? this.amount,
      adImages: adImages ?? this.adImages,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}