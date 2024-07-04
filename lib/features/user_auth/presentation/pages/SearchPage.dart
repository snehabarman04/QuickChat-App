import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/chatRoomPage.dart';
import 'package:firebase_testing/global/common/toast.dart';
import 'package:firebase_testing/main.dart';
import 'package:firebase_testing/models/ChatRoomModel.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final Usermodel userModel;
  final User firebaseUser;
  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(Usermodel targetUser) async {
    ChatRoomModel? chatRoom;
    //both the participants must be in the chatroom
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      //create a new chatroom
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 174, 232, 241),
          title: Text(
            "Search Chats",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 8, 85, 147)),
          ),
        ),
        body: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
            child: Image.asset(
              'login_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: "Email Adress"),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {});
                    },
                    color: Color.fromARGB(255, 20, 76, 122),
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 25),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where("email", isEqualTo: searchController.text)
                        .where("email", isNotEqualTo: widget.userModel.email)
                        .snapshots(),
                    //we don't want to give search results for the same logged in email
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          if (dataSnapshot.docs.length > 0) {
                            Map<String, dynamic> userMap = dataSnapshot.docs[0]
                                .data() as Map<String, dynamic>;
                            //because no other user will have the same email except 1
                            Usermodel searchedUser = Usermodel.fromMap(userMap);
                            return ListTile(
                              onTap: () async {
                                ChatRoomModel? chatroomModel =
                                    await getChatroomModel(searchedUser);

                                if (chatroomModel != null) {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatroomModel,
                                    );
                                  }));
                                }
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('profile_default.png'),
                                //NetworkImage(searchedUser.profilepic!),
                                backgroundColor:
                                    Color.fromARGB(255, 114, 193, 239),
                              ),
                              title: Text(searchedUser.fullname!),
                              subtitle: Text(searchedUser.email!),
                              trailing:
                                  Icon(Icons.keyboard_arrow_right_rounded),
                            );
                          } else {
                            return Text(
                              "No results found!",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 7, 88, 149)),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Text("An error has occured!");
                        } else {
                          return Text("No results Found!");
                        }
                      } else {
                        return CircularProgressIndicator(
                          color: const Color.fromARGB(255, 10, 64, 107),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
