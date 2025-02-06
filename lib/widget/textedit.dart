import 'package:flutter/material.dart';
import 'package:picturediary/manager/stablediffusion_controller.dart';
import 'package:picturediary/widget/calendar_screen.dart';
import 'package:picturediary/widget/result_screen.dart';

class TextEditPage extends StatefulWidget {
  String text;
  final DateTime selectedDate;
  TextEditPage({required this.text, required this.selectedDate});

  _EditTextPageState createState() => _EditTextPageState();
}

class _EditTextPageState extends State<TextEditPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.format_paint_outlined),
            onPressed: () async {
              //다음 페이지
              //List<String> imageList =  await StableManager().convertTextToImage(widget.text);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    selectedDate: widget.selectedDate,
                    images: [
                      // 예시 이미지 URL
                      'https://picsum.photos/seed/picsum/200/300',
                      'https://picsum.photos/seed/picsum/200/300',
                      'https://picsum.photos/seed/picsum/200/300',
                      'https://picsum.photos/seed/picsum/200/300',
                      'https://picsum.photos/seed/picsum/200/300',
                    ],
                    text: widget.text,
                  ),
                ),
              );

              if (result == true) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarScreen(),
                    ));
              }

              print(widget.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),

              Text(
                '일기를 다 작성했어요!',
                style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
              ),
              // 두 번째 줄
              Text(
                '내용을 보충해도 좋아요.',
                style: TextStyle(fontSize: 30, fontFamily: 'daehan'),
              ),
              SizedBox(height: 50),
              SingleChildScrollView(
                child: TextField(
                  controller: _controller,
                  onChanged: (newText) {
                    setState(() {
                      widget.text = newText;
                    });
                  },
                  minLines: 10,
                  maxLines: null,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '작성된 일기',
                    hintText: 'Start editing...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
