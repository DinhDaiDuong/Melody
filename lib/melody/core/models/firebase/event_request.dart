import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:melody/melody/core/models/event/event.dart';

class EventRequest {
  static Stream<List<Event>> search(String searchValue) =>
      FirebaseFirestore.instance.collection('Events').snapshots().map((event) =>
          event.docs
              .map((e) => Event.fromJson(e.data()))
              .where((event) =>
                  event.name.toLowerCase().contains(searchValue.toLowerCase()))
              .toList());
}
