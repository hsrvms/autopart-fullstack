// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'make_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Make _$MakeFromJson(Map<String, dynamic> json) => Make(
      makeId: (json['make_id'] as num).toInt(),
      makeName: json['make_name'] as String,
    );

Map<String, dynamic> _$MakeToJson(Make instance) => <String, dynamic>{
      'make_id': instance.makeId,
      'make_name': instance.makeName,
    };
