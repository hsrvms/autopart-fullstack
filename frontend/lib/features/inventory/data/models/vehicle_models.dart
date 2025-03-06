class Make {
  final int makeId;
  final String makeName;
  final String? country;
  final bool isActive;

  Make({
    required this.makeId,
    required this.makeName,
    this.country,
    required this.isActive,
  });

  factory Make.fromJson(Map<String, dynamic> json) {
    return Make(
      makeId: json['make_id'],
      makeName: json['make_name'],
      country: json['country'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class Model {
  final int modelId;
  final int makeId;
  final String modelName;
  final bool isActive;

  Model({
    required this.modelId,
    required this.makeId,
    required this.modelName,
    required this.isActive,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      modelId: json['model_id'],
      makeId: json['make_id'],
      modelName: json['model_name'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class Submodel {
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
  final bool isActive;

  Submodel({
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
    required this.isActive,
  });

  factory Submodel.fromJson(Map<String, dynamic> json) {
    return Submodel(
      submodelId: json['submodel_id'],
      modelId: json['model_id'],
      submodelName: json['submodel_name'],
      yearFrom: json['year_from'],
      yearTo: json['year_to'],
      engineType: json['engine_type'],
      engineDisplacement: json['engine_displacement'].toDouble(),
      fuelType: json['fuel_type'],
      transmissionType: json['transmission_type'],
      bodyType: json['body_type'],
      isActive: json['is_active'] ?? true,
    );
  }
}
