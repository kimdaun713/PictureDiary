import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StableManager {
  Future<List<String>> convertTextToImage(String prompt) async {
    final url = Uri.parse('http://..:8889/stable_diffusion_2/invoke_inference');

    // 요청 본문 데이터 설정
    Map<String, dynamic> requestData = {
      "prompt": prompt,
      "negative_prompt": "no sexual,",
      "seed": 1001,
      "height": 1024,
      "width": 1024,
      "scheduler": "KLMS",
      "num_inference_steps": 30,
      "guidance_scale": 10,
      "strength": 0.5,
      "num_images": 5
    };

    print(requestData);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode != 200) {
        print("200 실패");
        print(response.body);
        return ["null"];
      } else {
        try {
          final responseData = jsonDecode(response.body);
          final resultImages = responseData['images'] as List<dynamic>;
          return resultImages.map((image) => image.toString()).toList();
        } catch (e) {
          print("응답 데이터 파싱 오류: $e");
          return ["null"];
        }
      }
    } catch (e) {
      print("HTTP 요청 실패: $e");
      return ["null"];
    }
  }
}
