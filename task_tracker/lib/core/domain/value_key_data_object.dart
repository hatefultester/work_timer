import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'id.dart';

abstract class Model<T extends Id> implements ValueKeyDataObjectInterface {
  const Model(this.id, this.creationTime);

  final T id;

  final DateTime creationTime;

  Map<String, dynamic> get map;

  @override
  List<Object?> get props;

  @override
  bool? get stringify => true;

  @override
  ValueKeyDataObject toValueKeyDataObject() {
    return ValueKeyDataObject.fromMap(key: id.toJson(), map: map);
  }
}

abstract interface class ValueKeyDataObjectInterface extends Equatable {
  const ValueKeyDataObjectInterface();

  ValueKeyDataObject toValueKeyDataObject();

  @override
  List<Object?> get props;
}

class ValueKeyDataObject extends Equatable {
  const ValueKeyDataObject({
    required this.key,
    required this.jsonData,
  });

  factory ValueKeyDataObject.fromMap({required String key, required Map<String, dynamic> map}) {
    return ValueKeyDataObject(key: key, jsonData: jsonEncode(map));
  }

  final String key;
  final dynamic jsonData;

  Map<String, dynamic>? get map {
    try {
      final map = jsonDecode(jsonData) as Map<String, dynamic>;
      return map;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [key, jsonData];
}
