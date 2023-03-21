import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/utils/AuthStatusEnum.dart';
import 'package:location/utils/snackbar.dart';
import 'package:http/http.dart';

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

      final response = await dio.post(
          'https://uz7rggk5of.execute-api.eu-west-1.amazonaws.com/prod/auth/signin',
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }),
          data: jsonEncode({"username": email, "password": password}));

      final String accessToken = response.data["token"]!;
      user = User(email: email, notificationToken: accessToken);

      return accessToken;
    } catch (error) {
      Utils.customSnackBar(context, error.toString());
      print(error.toString());
      return "-1234";
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
