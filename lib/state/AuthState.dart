import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/utils/AuthStatusEnum.dart';
import 'package:location/utils/snackbar.dart';
import 'package:http/http.dart';
import 'dart:developer';

import 'AppState.dart';
import 'dart:developer';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  User? user;
  late String userId;

  void openSignUpPage() {
    print('opensignUpPage');
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  Future<String?> signIn(String email, String password,
      {required BuildContext context}) async {
    try {
      isWorking = true;
      // Utils.customSnackBar(context, 'Doing SignIn');
      final dio = Dio();

      log("Cognito Signin start");
      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/signin',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode({"username": email, "password": password}));

      log("Cognito Signin end");

      log(response.data.toString());
      log(response.statusCode.toString());

      final String accessToken = response.data["token"]!;
      user = User(email: email, notificationToken: accessToken);

      return accessToken;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.data["message"]["code"]);
        print(e.response?.headers);
        print(e.response?.requestOptions);
        if (e.response?.data["message"]["code"] == "UserNotFoundException") {
          print("No estas confirmao paqui");
          // We should open a new interface in order to confirm cognito user
        }
      } else {
        print(e.requestOptions);
        print(e.message);
      }
      return e.message;
    } finally {
      isWorking = false;
    }
  }

  Future<bool?> signUp(String username, String email, String password,
      {required BuildContext context}) async {
    try {
      isWorking = true;
      // Utils.customSnackBar(context, 'Doing SignIn');
      final dio = Dio();
      print("VAMOS A COGNITO");
      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/signup',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode(
              {"username": username, "email": email, "password": password}));
      print("COGNIT TE DEVUELVE: ");
      print(response);
      // final String accessToken = response.data["token"]!;
      // user = User(email: email, notificationToken: accessToken);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("ERROR makeing post to sign up");
      print(error);
      return false;
    } finally {
      isWorking = false;
    }
  }

  Future<User?> getCurrentUser({required BuildContext context}) async {
    try {
      isWorking = true;

      final head = Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        'Authorization': user!.notificationToken
      });

      final dio = Dio();
      final response = await dio.get(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/current_user',
          options: head);

      final sub = response.data["sub"];
      // print("Tras buscar el usuario en el API Gateway");
      // print(sub);
      user?.setUserId(sub);

      print("El usuario actual es: ");

      final ID = user!.userId;
      print(ID);
      // Utils.customSnackBar(context, "el id: $ID");

      if (user != null) {
        // await getProfileUser();
        authStatus = AuthStatus.LOGGED_IN;
        // userId = user!.uid;
        userId = 'pepito123';
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      isWorking = false;
      return user;
    } catch (error) {
      isWorking = false;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }
}
