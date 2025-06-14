import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:melody/melody/core/models/firebase/instrument_request.dart';
import 'package:melody/melody/core/models/instrumentModel/instrumentModel.dart';

class DetailInstrumentScreen extends StatefulWidget {
  final InstrumentModel instrument;
  const DetailInstrumentScreen({super.key, required this.instrument});

  @override
  State<DetailInstrumentScreen> createState() => _DetailInstrumentScreenState();
}

class _DetailInstrumentScreenState extends State<DetailInstrumentScreen> {
  var _controller = QuillController.basic();
  Future<void> loadQuill() async {
    String description =
        await InstrumentRequest.getDescription(widget.instrument.id);
    setState(() {
      _controller = QuillController(
          document: Document.fromJson(jsonDecode(description)),
          selection: TextSelection.collapsed(offset: 0));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadQuill();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Detail Instrument'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<InstrumentModel>(
              future: InstrumentRequest.getById(widget.instrument.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Text(
                        snapshot.data!.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(snapshot.data!.image),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 350,
                        // child: QuillEditor.basic(
                        //   configurations: QuillEditorConfigurations(
                        //     // controller: _controller,
                        //     // sharedConfigurations:
                        //     //     const QuillSharedConfigurations(
                        //     //   locale: Locale('de'),
                        //     // ),
                        //   ),
                        // ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }
                return Container();
              }),
        ),
      ),
    );
  }
}
