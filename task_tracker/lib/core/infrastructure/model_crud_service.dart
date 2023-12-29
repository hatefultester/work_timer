import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../domain/custom_failure.dart';
import '../domain/value_key_data_object.dart';
import 'local_storage_data_source.dart';

abstract interface class ModelCrudServiceInterface<T extends Model> {
  String get modelPrefix;

  Future<Either<CustomFailure, List<T>>> readAll();

  Future<Either<CustomFailure, Unit>> create(T model);

  Future<Either<CustomFailure, Unit>> update(T model);

  Future<Either<CustomFailure, Unit>> delete(T model);

  Future<Either<CustomFailure, Unit>> deleteAll();

  Future<void> fetch();

  String? validateModelCreation(T model);

  String? validateModelUpdate(T oldModel, T newModel);

  T? modelValueKeyDataObjectMapper(ValueKeyDataObject object);
}

class CrudServiceValidationFailure extends CustomFailure {
  const CrudServiceValidationFailure({required super.message});
}

enum ModelCrudServiceStatus {
  initial,
  loading,
  ready;

  bool get isLoading => this == ModelCrudServiceStatus.loading;

  bool get isReady => this == ModelCrudServiceStatus.ready;

  bool get isInitial => this == ModelCrudServiceStatus.initial;
}

abstract class ModelCrudService<T extends Model> extends GetxService implements ModelCrudServiceInterface<T> {
  ModelCrudService(this._localStorageDataSource, this.logger, {this.showInfoLogs = false});

  final Logger logger;

  final bool showInfoLogs;

  final LocalStorageDataSourceInterface _localStorageDataSource;

  final Rx<List<T>> _modelsCache = Rx(List.empty(growable: true));

  final Rx<ModelCrudServiceStatus> _status = Rx(ModelCrudServiceStatus.initial);

  Rx<ModelCrudServiceStatus> get status => _status;

  Rx<List<T>> get cacheObservable => _modelsCache;

  @override
  Future<void> fetch() async {
    _setLoading();
    final storageResult = await readAll();
    storageResult.fold(
          (failure) => _setReady(),
          (models) {
        _modelsCache.value = models;
        _setReady();
      },
    );
  }

  _setLoading() {
    _status.value = ModelCrudServiceStatus.loading;
  }

  _setReady() {
    _status.value = ModelCrudServiceStatus.ready;
  }

  @override
  void onClose() {
    _status.close();
    _modelsCache.close();
    super.onClose();
  }

  @override
  Future<Either<CustomFailure, Unit>> create(T model) async {
    i(String message) => logInfo(message, process: 'create model $model');
    try {
      _setLoading();
      final validationError = validateModelCreation(model);
      i('validationError: $validationError');
      if (validationError != null) {
        final error = CrudServiceValidationFailure(message: validationError);
        logError(error, process: 'create model $model');
        return left(error);
      }
      await _localStorageDataSource.storeModel(model);
      final modelsCache = _modelsCache.value..removeWhere((element) => element.id == model.id);
      _modelsCache.value = List.from(modelsCache)..add(model);
      i('model created, current cache: ${_modelsCache.value}');
      _setReady();
      return right(unit);
    } on Exception catch (e, s) {
      _setReady();
      final error = CustomFailure(message: 'Error happen during creation of model $model', exception: e, stackTrace: s);
      logError(error, process: 'create model $model');
      return left(error);
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> delete(T model) async {
    i(String message) => logInfo(message, process: 'delete model $model');
    try {
      _setLoading();
      await _localStorageDataSource.deleteModel(model);
      final modelsCache = _modelsCache.value..removeWhere((element) => element.id == model.id);
      _modelsCache.value = List.from(modelsCache);
      i('model deleted, current cache: ${_modelsCache.value}');
      _setReady();
      return right(unit);
    } on Exception catch (e, s) {
      _setReady();
      final error = CustomFailure(message: 'Error happen during deletion of model $model', exception: e, stackTrace: s);
      logError(error, process: 'delete model $model');
      return left(error);
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> deleteAll() async {
    i(String message) => logInfo(message, process: 'delete all models');
    try {
      _setLoading();
      await _localStorageDataSource.eraseDataWithPrefix(modelPrefix);
      _modelsCache.value = List.empty(growable: true);
      i('all models deleted, current cache: ${_modelsCache.value}');
      _setReady();
      return right(unit);
    } on Exception catch (e, s) {
      _setReady();
      final error = CustomFailure(message: 'Error happen during deletion of all models', exception: e, stackTrace: s);
      logError(error);
      return left(error);
    }
  }

  @override
  Future<Either<CustomFailure, List<T>>> readAll() {
    i(String message) => logInfo(message, process: 'read all models');
    try {
      _setLoading();
      return _localStorageDataSource.getValueKeyDataObjectsWithPrefix(modelPrefix).then(
        (valueKeyDataObjects) {
          final models = valueKeyDataObjects
              .map((valueKeyDataObject) {
                return modelValueKeyDataObjectMapper(valueKeyDataObject);
              })
              .nonNulls
              .toList();
          _modelsCache.value = models;
          i('models read, current cache: ${_modelsCache.value}');
          _setReady();
          return right(models);
        },
      );
    } on Exception catch (e, s) {
      _setReady();
      final error = CustomFailure(message: 'Error happen during reading of all models', exception: e, stackTrace: s);
      logError(error);
      return Future.value(left(error));
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> update(T model) async {
    i(String message) => logInfo(message, process: 'update model $model');

    try {
      _setLoading();
      final validationError =
          validateModelUpdate(_modelsCache.value.firstWhere((element) => element.id == model.id), model);
      i('validationError: $validationError');
      if (validationError != null) {
        final error = CrudServiceValidationFailure(message: validationError);
        logError(error, process: 'update model $model');
        return left(error);
      }
      await _localStorageDataSource.storeModel(model);
      final modelsCache = _modelsCache.value..removeWhere((element) => element.id == model.id);
      _modelsCache.value = List.from(modelsCache)..add(model);
      i('model updated, current cache: ${_modelsCache.value}');
      _setReady();
      return right(unit);
    } on Exception catch (e, s) {
      _setReady();
      final error = CustomFailure(message: 'Error happen during update of model $model', exception: e, stackTrace: s);
      logError(error, process: 'update model $model');
      return left(error);
    }
  }

  @override
  String? validateModelCreation(T model);

  @override
  String? validateModelUpdate(T oldModel, T newModel);

  @override
  String get modelPrefix;

  @override
  T? modelValueKeyDataObjectMapper(ValueKeyDataObject object);

  logError(CustomFailure failure, {String? process}) {
    logger.e('Error in $runtimeType $process:\n${failure.toString()}');
  }

  logInfo(String message, {String? process}) {
    if (!showInfoLogs) return;
    logger.i('Info in $runtimeType $process:\n$message');
  }
}
