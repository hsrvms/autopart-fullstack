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
      modelId: json['model_id'] as int,
      makeId: json['make_id'] as int,
      modelName: json['model_name'] as String,
      makeName: json['make_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'make_id': makeId,
      'model_name': modelName,
      'make_name': makeName,
    };
  }

  String get name => modelName;
}
