import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_testing/main.dart';
import 'package:firebase_testing/models/ChatRoomModel.dart';
import 'package:firebase_testing/models/MessageModel.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  //the user which we are interacting with
  final Usermodel targetUser;
  final ChatRoomModel chatroom;

  //our usermodel
  final Usermodel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  //sending messages
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      print("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 163, 201, 220),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[200],
                backgroundImage: AssetImage('profile_default.png'),
                //NetworkImage(widget.targetUser.profilepic.toString()),
              ),
              SizedBox(width: 10),
              Text(
                widget.targetUser.fullname.toString(),
                style: TextStyle(
                    color: Color.fromARGB(255, 9, 64, 109),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
        ),
        body: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
            child: Image.asset(
              'chat_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    // chat section
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .orderBy("createdon", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.hasData) {
                                QuerySnapshot dataSnapshot =
                                    snapshot.data as QuerySnapshot;

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    MessageModel currentMessage =
                                        MessageModel.fromMap(
                                            dataSnapshot.docs[index].data()
                                                as Map<String, dynamic>);
                                    return Row(
                                      mainAxisAlignment:
                                          (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: (currentMessage.sender ==
                                                      widget.userModel.uid)
                                                  ? Color.fromARGB(
                                                      255, 16, 134, 188)
                                                  : Color.fromARGB(
                                                      255, 94, 121, 134),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              currentMessage.text.toString(),
                                              style: TextStyle(
                                                color: (currentMessage.sender ==
                                                        widget.userModel.uid)
                                                    ? Color.fromARGB(
                                                        255, 255, 255, 255)
                                                    : Color.fromARGB(
                                                        255, 255, 255, 255),
                                              ),
                                            )),
                                      ],
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                      "No Internet! Please try again later"),
                                );
                              } else {
                                return Center(
                                  child: Text(
                                      "Say Hi! to ${widget.targetUser.fullname}"),
                                );
                              }
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: const Color.fromARGB(255, 8, 83, 145),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Color.fromARGB(255, 19, 87, 146),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            style: TextStyle(
                              color: Color.fromARGB(255, 178, 228, 251),
                            ),
                            cursorColor: Colors.blue[50],
                            controller: messageController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Enter message",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 186, 234, 250),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: Icon(
                            Icons.send_rounded,
                            color: Color.fromARGB(255, 147, 210, 240),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
