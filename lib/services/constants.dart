// ignore_for_file: constant_identifier_names

class ApiConstants {
  static String basePath = "";
}

const tokenKey = 'TokenKey';
const entityId = 'EntityId';

class ErrosStatusCode {
  static const int invalidRequest = 400;
  static const int unauthorized = 401;
  static const int prohibeted = 403;
  static const int notFind = 404;
  static const int notAllowed = 405;
}

class ApiErrors {
  static const connectionError = 'Não foi possível conectar ao servidor. Verifique sua internet.';
  static const unexpectedError = 'Algo deu errado. Tente novamente.';
}
