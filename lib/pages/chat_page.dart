import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_chat_app/models/message.dart';
import 'package:firebase_chat_app/services/auth_service.dart';
import 'package:firebase_chat_app/services/media_service.dart';
import 'package:firebase_chat_app/services/storage_service.dart';
import 'package:firebase_chat_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/chat.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';


class ChatPage extends StatefulWidget{

  final UserProfile chatUser;

  ChatPage({required this.chatUser });
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid,
        firstName: _authService.user!.displayName);
    otherUser = ChatUser(id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatUser.name!),),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return StreamBuilder(stream:_databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context,snapshot){
      Chat? chat = snapshot.data?.data();
      List<ChatMessage> messages = [];
      if(chat != null && chat.messages != null){
        messages = _generateChatMessageList(chat.messages!);
      }
    return DashChat(
    messageOptions: const MessageOptions(
    showOtherUsersAvatar: true,

    showTime: true,
    ),
    inputOptions:  InputOptions(
    alwaysShowSend: true,
      trailing: [
        _mediaMessageButton(),
      ],
    ),
    currentUser: currentUser!,
    onSend: _sendMessage,
    messages: messages);
    }

        );
}

  Future<void> _sendMessage(ChatMessage chatmessage) async {



    if (!(await _databaseService.checkChatExists(currentUser!.id, otherUser!.id))) {
      await _databaseService.createNewChat(currentUser!.id, otherUser!.id);
    }



    if(chatmessage.medias?.isNotEmpty ?? false){
      if(chatmessage.medias!.first.type == MediaType.image ){
        Message message = Message(
            senderID: chatmessage.user.id,
            content: chatmessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatmessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
      }
    }else{
      Message message = Message(
          senderID: currentUser!.id,
          content: chatmessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatmessage.createdAt));
      await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message);
    }
    }


  List<ChatMessage> _generateChatMessageList(List<Message> messages){
    List<ChatMessage> ChatMessages = messages.map((m){
      if(m.messageType == MessageType.Image){
          return ChatMessage(
              user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
              createdAt: m.sentAt!.toDate(),
              medias:[
                ChatMedia(
                    url: m.content!,
                    fileName: "",
                    type: MediaType.image)
              ] );
      }else{
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }

    }).toList();
    ChatMessages.sort((a,b){
      return b.createdAt.compareTo(a.createdAt);
    });
    return ChatMessages;
  }

  Widget _mediaMessageButton(){
    return IconButton(onPressed:()async{
      File? file = await  _mediaService.getImageFromGallery();
      if(file != null){
        String chatID = generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
        String? downloadURL = await _storageService.uploadImageToChat(
            file: file, chatID: chatID);
        if(downloadURL != null){
          ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [ChatMedia(
                  url: downloadURL,
                  fileName: "",
                  type: MediaType.image)] );
          
          _sendMessage(chatMessage);
        }
      }
    },
        icon: Icon(Icons.image,
        color: Colors.blue,));
  }

}


