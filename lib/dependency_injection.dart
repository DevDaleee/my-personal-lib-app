import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.allowReassignment = true;
  sl.registerLazySingleton<ApiServices>(() => ApiServices(Dio()));
  sl.registerLazySingleton<SecurityStorage>(() => SecurityStorage());
}
