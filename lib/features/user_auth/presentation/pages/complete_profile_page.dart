import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/home_page.dart';
import 'package:firebase_testing/global/common/toast.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'sign_up_page.dart';
import 'package:firebase_testing/main.dart';
import 'package:firebase_testing/features/user_auth/firebase_authentication/firebase_auth_services.dart';

class CompleteProfilePage extends StatefulWidget {
  final Usermodel userModel;
  final User firebaseUser;
  const CompleteProfilePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if (pickedfile != null) {
      cropImage(pickedfile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoSelectionOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Choose Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo),
                  title: Text("Choose from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take Photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname == "") {
      showToast(message: "These fields cannot be empty!");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    try {
      String fullname = fullNameController.text.trim();

      if (fullname.isEmpty) {
        showToast(message: "Full Name cannot be empty!");
        return; // Exit the function if full name is empty
      }

      if (imageFile != null) {
        // Upload the user's profile picture to Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("profilepictures")
            .child(widget.userModel.uid.toString())
            .putFile(imageFile!);

        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        widget.userModel.profilepic = imageUrl;
      }

      // Update Firestore with user data
      widget.userModel.fullname = fullname;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap())
          .then((value) {
        showToast(message: "Data Successfully Uploaded!");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }));
      });
    } catch (e) {
      print(e);
      showToast(message: "Error uploading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 174, 232, 241),
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Complete Your Profile",
            style: TextStyle(
                fontSize: 30,
                color: Colors.lightBlue[900],
                fontWeight: FontWeight.bold),
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
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: ListView(
                children: [
                  CupertinoButton(
                    onPressed: () {
                      showPhotoSelectionOptions();
                    },
                    padding: EdgeInsets.all(0),
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey[300],
                      radius: 50,
                      backgroundImage:
                          imageFile != null ? FileImage(imageFile!) : null,
                      child: (imageFile == null)
                          ? Icon(
                              Icons.person,
                              size: 60,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    color: Color.fromARGB(255, 20, 76, 122),
                    child: Text("Submit"),
                    onPressed: () {
                      checkValues();
                    },
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
