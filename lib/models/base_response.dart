class BaseResponse<T> {
  final bool isSuccess;
  final List<T> responseData;

  BaseResponse({
    required this.isSuccess,
    required this.responseData,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final responseDataList = json['responseData'] as List<dynamic>;
    return BaseResponse(
      isSuccess: json['isSuccess'] ?? false,
      responseData: responseDataList.map((item) => fromJson(item)).toList(),
    );
  }
}