import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//for accessing dialogue boxes and alerts easily
class UIHelper {
  static void showLoadingDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.indigo[900],
            ),
            SizedBox(
              height: 30,
            ),
            Text(title),
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        //cannot access the outside area of the dialogue box
        builder: (context) {
          return loadingDialog;
        });
  }

  static void showAlertDialog(
      BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        CupertinoButton(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(20),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "OK",
            style: TextStyle(color: Colors.lightBlue[900]),
          ),
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }
}
