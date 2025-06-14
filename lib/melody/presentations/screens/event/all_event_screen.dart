import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/melody/core/helper/text_styles.dart';
import 'package:melody/melody/core/models/event/event.dart';
import 'package:melody/melody/core/models/firebase/event_request.dart';
import 'package:melody/melody/presentations/screens/event/add_event.dart';

import '../../../core/constants/color_palatte.dart';
import 'widgets/event_item.dart';

class AllEventScreen extends StatefulWidget {
  const AllEventScreen({super.key});

  @override
  State<AllEventScreen> createState() => _AllEventScreenState();
}

class _AllEventScreenState extends State<AllEventScreen> {
  TextEditingController searchController = TextEditingController();
  String searchValue = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'All Events',
            style: TextStyle(fontSize: 20).whiteTextColor,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => AddEventSrceen());
              },
              icon: Icon(
                Icons.add,
                color: ColorPalette.secondColor,
                size: 40,
              ),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                controller: searchController,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    hintStyle: TextStyle(color: Color(0xffFFFFFF)),
                    fillColor: ColorPalette.primaryColor,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    hintText: 'Search event...',
                    prefixIconColor: Color(0xffffffff),
                    prefixIcon: Icon(Icons.search)),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder<List<Event>>(
                    stream: EventRequest.search(searchValue),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // While waiting for data, show a loading indicator
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // If there's an error with the stream, display an error message
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemBuilder: ((context, index) {
                              return EventItem(
                                event: snapshot.data![index],
                              );
                            }),
                            separatorBuilder: ((context, index) {
                              return SizedBox(
                                height: 10,
                              );
                            }),
                            itemCount: snapshot.data!.length);
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
