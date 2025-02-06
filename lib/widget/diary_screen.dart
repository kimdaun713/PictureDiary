import 'dart:io';

import 'package:picturediary/SDK/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DairyPage extends StatelessWidget {
  final ImageData diaryEntry;

  DairyPage({required this.diaryEntry});

  @override
  Widget build(BuildContext context) {
    List<String> contents = diaryEntry.text.split('');
    DateTime parsedDate = DateTime.parse(diaryEntry.date);

    String formattedDate = DateFormat('yyyy년 MM월 dd일').format(parsedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.fill,
        )),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range),
                        SizedBox(width: 8),
                        Text(
                          '날짜: $formattedDate',
                          style: TextStyle(
                              fontFamily: 'daehan',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.wb_sunny),
                        SizedBox(width: 8),
                        Text(
                          'Sunny',
                          style: TextStyle(fontFamily: 'daehan'),
                        ), // 날씨 설명
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Image.file(
                  File(diaryEntry.image),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        index < contents.length
                            ? contents[index]
                            : '', // 존재하는 글자면 표시, 그렇지 않으면 빈 칸
                        style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
