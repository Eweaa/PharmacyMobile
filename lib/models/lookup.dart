class Lookup {
  final int id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String internalCode;
  final String internalRef;
  final bool isActive;

  Lookup({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.internalCode,
    required this.internalRef,
    required this.isActive,
  });

  factory Lookup.fromJson(Map<String, dynamic> json) {
    return Lookup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      internalCode: json['internalCode'] ?? '',
      internalRef: json['internalRef'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}