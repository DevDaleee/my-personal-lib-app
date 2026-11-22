import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/pages/helpers/toast.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';
import 'package:toastification/toastification.dart';

part 'auth_controller.g.dart';

class AuthController = AuthControllerBase with _$AuthController;

abstract class AuthControllerBase with Store {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rpasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final UserServices userServices = GetIt.I.get<UserServices>();

  @observable
  bool isLoading = false;

  // As respostas do UserServices têm sempre: status_code, data e error.

  @action
  Future<void> submitLogin(GlobalKey<FormState> formKey, BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    try {
      isLoading = true;
      await _login(context);
    } catch (e) {
      _submissionFailure("Erro ao entrar", "Algo deu errado. Tente novamente.");
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> submitRegister(GlobalKey<FormState> formKey, BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    try {
      isLoading = true;
      final response = await userServices.register(emailController.text, passwordController.text, nameController.text);
      if (response["status_code"] != 201) {
        _submissionFailure("Erro ao cadastrar", response["error"]);
        return;
      }
      // A pessoa entra por conta própria: volta para o login com o e-mail já preenchido.
      passwordController.clear();
      rpasswordController.clear();
      nameController.clear();
      showToast("Conta criada", "Agora é só entrar com seu e-mail e senha.", ToastificationType.success);
      if (context.mounted) context.go('/');
    } catch (e) {
      _submissionFailure("Erro ao cadastrar", "Algo deu errado. Tente novamente.");
    } finally {
      isLoading = false;
    }
  }

  /// Faz o login com o e-mail e a senha digitados e, se der certo, salva o token e vai para a Home.
  Future<void> _login(BuildContext context) async {
    final response = await userServices.login(emailController.text, passwordController.text);
    if (response["status_code"] != 200) {
      _submissionFailure("Erro ao entrar", response["error"]);
      return;
    }
    // A API devolve {"token", "user_id"}.
    final data = response["data"] as Map<String, dynamic>;
    if (context.mounted) await _submissionSuccess(accessToken: data["token"] as String, userId: data["user_id"] as String?, context: context);
  }

  void showToast(String title, String description, ToastificationType type) {
    ToastService.show(key: 'auth-key', title: Text(title), description: Text(description), type: type, applyBlurEffect: true);
  }

  /// Processa o sucesso do login
  @action
  Future<void> _submissionSuccess({required String accessToken, String? userId, required BuildContext context}) async {
    try {
      await SecurityStorage.addAccessToken(accessKeyValue: accessToken, userIdValue: userId);
      _clearControllers();
      if (context.mounted) context.go('/home');
    } catch (e) {
      _submissionFailure("Erro ao entrar", "Não foi possível salvar o acesso. Tente novamente.");
    }
  }

  /// Libera recursos quando o controller não for mais necessário
  @action
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    rpasswordController.dispose();
    nameController.dispose();
  }

  /// Limpa os controllers
  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    rpasswordController.clear();
    nameController.clear();
  }

  /// Mostra o erro num toast (a mensagem vem pronta do UserServices).
  @action
  void _submissionFailure(String title, String? message) {
    showToast(title, message ?? "Algo deu errado. Tente novamente.", ToastificationType.error);
  }
}
