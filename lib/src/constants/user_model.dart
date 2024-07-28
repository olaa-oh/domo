// user model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String? id;
  final String email;
  final String name;
  final String phonenumber;
  final String password;
  final String? role;
  String? imageUrl ;

   UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.phonenumber,
    required this.password,
    this.role,
    this.imageUrl,
  });

  toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phonenumber': phonenumber,
      'password': password,
      'role': role,
      'imageUrl': imageUrl,
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data =  snapshot.data()!;
    return UserModel(
      id:  data['id'],
      email:  data['email'],
      name:  data['name'],
      phonenumber:  data['phonenumber'],
      password:  data['password'],
      role:  data['role'],
      imageUrl:  data['imageUrl'],
    );
  }
}
