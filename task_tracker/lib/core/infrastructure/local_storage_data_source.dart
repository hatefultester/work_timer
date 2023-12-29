import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker/core/domain/id.dart';

import '../domain/value_key_data_object.dart';

abstract interface class LocalStorageDataSourceInterface {
  const LocalStorageDataSourceInterface();

  // clears all data from the local storage
  Future<void> eraseAllData();

  // clears all data from the local storage with the given prefix
  Future<void> eraseDataWithPrefix(String prefix);

  // stores a single model in the local storage
  Future<void> storeModel<T extends Model>(T model);

  // deletes a single model in the local storage
  Future<void> deleteModel<T extends Model>(T model);

  // stores a list of models in the local storage
  Future<void> storeModels<T extends Model>(List<T> models);

  // returns a single model from the local storage
  Future<ValueKeyDataObject?> getValueKeyDataObject(String key);

  // returns a list of models from the local storage with the given prefix
  Future<List<ValueKeyDataObject>> getValueKeyDataObjectsWithPrefix(String prefix);
}

class LocalStorageDataSource implements LocalStorageDataSourceInterface {
  const LocalStorageDataSource();

  Future<SharedPreferences> get _sharedPreferences => SharedPreferences.getInstance();

  Future<Set<String>> get _keys async => (await _sharedPreferences).getKeys();

  Future<Set<String>> _keysWithPrefix(String prefix) async {
    final keys = await _keys;
    return keys.where((key) => key.startsWith(prefix)).toSet();
  }

  @override
  Future<void> eraseAllData() async {
    await (await _sharedPreferences).clear();
  }

  @override
  Future<void> eraseDataWithPrefix(String prefix) async {
    final keys = await _keysWithPrefix(prefix);
    for (final key in keys) {
      await (await _sharedPreferences).remove(key);
    }
  }

  Future<void> _storeValueKeyDataObject(ValueKeyDataObject valueKeyDataObject) async {
    await (await _sharedPreferences).setString(valueKeyDataObject.key, valueKeyDataObject.jsonData);
  }

  @override
  Future<void> storeModel<T extends Model>(T model) async {
    await _storeValueKeyDataObject(model.toValueKeyDataObject());
  }

  @override
  Future<void> storeModels<T extends Model>(List<T> models) async {
    for (final model in models) {
      await _storeValueKeyDataObject(model.toValueKeyDataObject());
    }
  }

  @override
  Future<ValueKeyDataObject?> getValueKeyDataObject(String key) async {
    final jsonData = (await _sharedPreferences).getString(key);
    if (jsonData == null) return null;
    return ValueKeyDataObject(key: key, jsonData: jsonData);
  }

  @override
  Future<List<ValueKeyDataObject>> getValueKeyDataObjectsWithPrefix(String prefix) async {
    final keys = await _keysWithPrefix(prefix);
    final valueKeyDataObjects = <ValueKeyDataObject>[];
    for (final key in keys) {
      final valueKeyDataObject = await getValueKeyDataObject(key);
      if (valueKeyDataObject != null) {
        valueKeyDataObjects.add(valueKeyDataObject);
      }
    }
    return valueKeyDataObjects;
  }

  @override
  Future<void> deleteModel<T extends Model<Id>>(T model) async {
    (await _sharedPreferences).remove(model.id.toJson());
  }
}
