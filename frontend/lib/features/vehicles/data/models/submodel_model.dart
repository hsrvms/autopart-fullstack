class SubModel {
  final int submodelId;
  final int modelId;
  final String submodelName;
  final int yearFrom;
  final int? yearTo;
  final String engineType;
  final double engineDisplacement;
  final String fuelType;
  final String transmissionType;
  final String bodyType;
  final String? modelName;
  final String? makeName;

  SubModel({
    required this.submodelId,
    required this.modelId,
    required this.submodelName,
    required this.yearFrom,
    this.yearTo,
    required this.engineType,
    required this.engineDisplacement,
    required this.fuelType,
    required this.transmissionType,
    required this.bodyType,
    this.modelName,
    this.makeName,
  });

  factory SubModel.fromJson(Map<String, dynamic> json) {
    return SubModel(
      submodelId: json['submodel_id'] as int,
      modelId: json['model_id'] as int,
      submodelName: json['submodel_name'] as String,
      yearFrom: json['year_from'] as int,
      yearTo: json['year_to'] as int?,
      engineType: json['engine_type'] as String,
      engineDisplacement: json['engine_displacement'] as double,
      fuelType: json['fuel_type'] as String,
      transmissionType: json['transmission_type'] as String,
      bodyType: json['body_type'] as String,
      modelName: json['model_name'] as String?,
      makeName: json['make_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submodel_id': submodelId,
      'model_id': modelId,
      'submodel_name': submodelName,
      'year_from': yearFrom,
      'year_to': yearTo,
      'engine_type': engineType,
      'engine_displacement': engineDisplacement,
      'fuel_type': fuelType,
      'transmission_type': transmissionType,
      'body_type': bodyType,
      'model_name': modelName,
      'make_name': makeName,
    };
  }

  String get name => submodelName;
}
