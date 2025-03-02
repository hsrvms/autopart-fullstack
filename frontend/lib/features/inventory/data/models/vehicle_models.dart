class Make {
  final int makeId;
  final String makeName;
  final String? country;

  Make({
    required this.makeId,
    required this.makeName,
    this.country,
  });

  factory Make.fromJson(Map<String, dynamic> json) {
    return Make(
      makeId: json['make_id'],
      makeName: json['make_name'],
      country: json['country'],
    );
  }
}

class Model {
  final int modelId;
  final int makeId;
  final String modelName;
  final String? makeName;

  Model({
    required this.modelId,
    required this.makeId,
    required this.modelName,
    this.makeName,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      modelId: json['model_id'],
      makeId: json['make_id'],
      modelName: json['model_name'],
      makeName: json['make_name'],
    );
  }
}

class Submodel {
  final int submodelId;
  final int modelId;
  final String submodelName;
  final int yearFrom;
  final int? yearTo;
  final String? engineType;
  final double? engineDisplacement;
  final String? fuelType;
  final String? transmissionType;
  final String? bodyType;
  final String? modelName;
  final String? makeName;

  Submodel({
    required this.submodelId,
    required this.modelId,
    required this.submodelName,
    required this.yearFrom,
    this.yearTo,
    this.engineType,
    this.engineDisplacement,
    this.fuelType,
    this.transmissionType,
    this.bodyType,
    this.modelName,
    this.makeName,
  });

  factory Submodel.fromJson(Map<String, dynamic> json) {
    return Submodel(
      submodelId: json['submodel_id'],
      modelId: json['model_id'],
      submodelName: json['submodel_name'],
      yearFrom: json['year_from'],
      yearTo: json['year_to'],
      engineType: json['engine_type'],
      engineDisplacement: json['engine_displacement']?.toDouble(),
      fuelType: json['fuel_type'],
      transmissionType: json['transmission_type'],
      bodyType: json['body_type'],
      modelName: json['model_name'],
      makeName: json['make_name'],
    );
  }
} 