import 'package:json_annotation/json_annotation.dart';

part 'make_model.g.dart';

@JsonSerializable()
class Make {
  @JsonKey(name: 'make_id')
  final int makeId;

  @JsonKey(name: 'make_name')
  final String makeName;

  @JsonKey(name: 'country')
  final String? country;

  Make({
    required this.makeId,
    required this.makeName,
    this.country,
  });

  factory Make.fromJson(Map<String, dynamic> json) {
    return Make(
      makeId: json['make_id'] as int,
      makeName: json['make_name'] as String,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make_id': makeId,
      'make_name': makeName,
      'country': country,
    };
  }

  String get name => makeName;
}
