import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_testing/features/user_auth/firebase_authentication/firebase_auth_services.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/SearchPage.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/chatRoomPage.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_testing/global/common/toast.dart';
import 'package:firebase_testing/models/ChatRoomModel.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Usermodel userModel;
  final User firebaseUser;
  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 174, 232, 241),
          centerTitle: true,
          title: Text(
            "Recent Chats",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 74, 94)),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ],
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${widget.userModel.uid}",
                        isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;

                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  Usermodel targetUser =
                                      userData.data as Usermodel;

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(255, 138, 166,
                                              186)!, // Border color
                                          width: 0.5, // Border width
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return ChatRoomPage(
                                              chatroom: chatRoomModel,
                                              firebaseUser: widget.firebaseUser,
                                              userModel: widget.userModel,
                                              targetUser: targetUser,
                                            );
                                          }),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.lightBlue[100],
                                        backgroundImage:
                                            AssetImage('profile_default.png'),
                                        //NetworkImage(targetUser.profilepic.toString()),
                                      ),
                                      title: Text(
                                        targetUser.fullname.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 11, 91, 132),
                                        ),
                                      ),
                                      subtitle: (chatRoomModel.lastMessage
                                                  .toString() !=
                                              "")
                                          ? Text(
                                              chatRoomModel.lastMessage
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.lightBlue[800],
                                                  fontSize: 14),
                                            )
                                          : Text(
                                              "Say Hi! to ${targetUser.fullname.toString()}",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                      trailing: Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        color:
                                            Color.fromARGB(255, 150, 168, 181),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 4, 83, 116),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              child: CupertinoButton(
                padding: EdgeInsets.all(0),
                borderRadius: BorderRadius.circular(60),
                color: Color.fromARGB(255, 111, 193, 209),
                child: Icon(
                  Icons.search_rounded,
                  color: Color.fromARGB(255, 6, 58, 100),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser);
                  }));
                },
              ),
            ),
          ),
        ]));
  }
}
