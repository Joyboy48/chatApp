import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ChatTile extends StatelessWidget{
  final UserProfile userProfile;
  final Function onTap;
  @override

  ChatTile({required this.userProfile,required this.onTap});

  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){onTap();},
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!,),
      ),
      title: Text(userProfile.name!,),
    );
  }
  
}