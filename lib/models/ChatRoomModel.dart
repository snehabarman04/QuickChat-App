class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String?
      lastMessage; // last message in the chatroom to be viewed on the home page

  ChatRoomModel({this.chatroomid, this.participants, this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map['chatroomid'];
    participants = map['participants'];
    lastMessage = map['lastmessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastmessage': lastMessage
    };
  }
}
