import 'package:equatable/equatable.dart';

class User extends Equatable {
  String? email;
  String? userId;
  String? displayName;
  String? userName;
  String? profilePic;
  String? location;
  String? createdAt;
  bool? isVerified;
  String? notificationToken;

  User(
      {this.email,
      this.userId,
      this.displayName,
      this.userName,
      this.profilePic,
      this.location,
      this.createdAt,
      this.isVerified,
      this.notificationToken});

  void setUserId(String nuserId) {
    userId = nuserId;
  }

  toJson() {
    return {
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'profilePic': profilePic,
      'location': location,
      'createdAt': createdAt,
      'userName': userName,
      'isVerified': isVerified ?? false,
      'notificationToken': notificationToken,
    };
  }

  User.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }

    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    location = map['location'];
    createdAt = map['createdAt'];
    userName = map['userName'];
    notificationToken = map['notificationToken'];
    isVerified = map['isVerified'] ?? false;
  }

  @override
  List<Object?> get props => [
        email,
        userId,
        displayName,
        userName,
        profilePic,
        location,
        createdAt,
        isVerified,
        notificationToken,
      ];
}
