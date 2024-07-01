import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/models/chat.dart';
import 'package:firebase_chat_app/models/user_profile.dart';
import 'package:firebase_chat_app/utils.dart';

import '../models/message.dart';
import 'auth_service.dart';
import 'package:get_it/get_it.dart';


class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  late AuthService _authService;

  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    _setupCollectionReference();
    _authService = _getIt.get<AuthService>();

  }

  void _setupCollectionReference() {
    _userCollection =
        _firebaseFirestore.collection('user').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
            fromFirestore: (snapshots,_)=>
            Chat.fromJson(snapshots.data()!),
            toFirestore: (chat,_) => chat.toJson());
  }

  Future<void> CreateUserProfile({required UserProfile userProfile}) async {
    await _userCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _userCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2)async{
     String ChatID =  generateChatID(uid1: uid1, uid2: uid2);
     final result = await _chatCollection?.doc(ChatID).get();
     if(result!= null){
       return result.exists;
     }
     return false;
  }

  Future<void>  createNewChat(String uid1, String uid2)async{
     String chatID = generateChatID(uid1: uid1, uid2: uid2);
     final docRef = _chatCollection!.doc(chatID);
     final chat = Chat(id: chatID, participants: [uid1,uid2], messages: []);
     await docRef.set(chat);
  }

  Future<void> sendChatMessage (String uid1,String uid2,Message message)async{
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    await docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson(),])
    });

}

    Stream<DocumentSnapshot<Chat>> getChatData(String uid1,String uid2){
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatID).snapshots() as Stream<DocumentSnapshot<Chat>> ;
  }
}

