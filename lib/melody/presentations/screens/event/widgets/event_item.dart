import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:melody/melody/core/constants/color_palatte.dart';
import 'package:melody/melody/core/models/event/event.dart';
import 'package:intl/intl.dart';
import 'package:melody/melody/presentations/screens/event/edit_event.dart';

class EventItem extends StatelessWidget {
  final Event event;
  const EventItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('MMMM dd, yyyy HH:mm:ss', 'en_US');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Change the color of the container
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(0.5), // Change the color of the shadow
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    image: NetworkImage(event.image), fit: BoxFit.cover)),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.format(DateTime.parse(event.startAt)),
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    event.name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: ColorPalette.secondColor,
                      ),
                      Text(
                        event.location,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.to(EditEventSrceen(id: event.id));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('Events')
                  .doc(event.id)
                  .delete()
                  .then((_) {
                Fluttertoast.showToast(
                  msg: "Please fill all the fields!",
                );
              }).catchError((error) {
                print('Failed to delete event: $error');
              });
            },
          ),
        ],
      ),
    );
  }
}
