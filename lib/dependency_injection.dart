import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/controllers/auth_controller.dart';
import 'package:my_personal_lib_app/controllers/book_detail_controller.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/controllers/new_book_controller.dart';
import 'package:my_personal_lib_app/controllers/profile_controller.dart';
import 'package:my_personal_lib_app/controllers/stats_controller.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.allowReassignment = true;
  sl.registerLazySingleton<ApiServices>(() => ApiServices(Dio()));
  sl.registerLazySingleton<SecurityStorage>(() => SecurityStorage());
  sl.registerLazySingleton<AuthController>(() => AuthController());
  sl.registerLazySingleton<UserServices>(() => UserServices());
  sl.registerLazySingleton<BookServices>(() => BookServices());
  sl.registerLazySingleton<StatsServices>(() => StatsServices());
  sl.registerLazySingleton<LibraryController>(() => LibraryController());
  sl.registerLazySingleton<ProfileController>(() => ProfileController());
  sl.registerLazySingleton<StatsController>(() => StatsController());
  // Factory: formulário novo a cada abertura da tela.
  sl.registerFactory<NewBookController>(() => NewBookController());
  // Factory: cada abertura do Detalhe tem o seu livro.
  sl.registerFactory<BookDetailController>(() => BookDetailController());
}
