import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../screens/settings_menu/settings_controller.dart';

class ChatGPTMessage {
  String content;
  bool isSent;

  ChatGPTMessage({required this.content, required this.isSent});
}

class ChatGPTApiResponse {
  bool? success;
  dynamic data;
  String? message;
  dynamic usage;

  ChatGPTApiResponse();

  factory ChatGPTApiResponse.fromJson(dynamic json) {
    ChatGPTApiResponse model = ChatGPTApiResponse();
    model.success = json['status'] == 200;
    model.data = json['choices'];
    model.message = json['message'];
    model.usage = json['usage'];

    return model;
  }
}

class ChatGPTController extends GetxController {
  final SettingsController _settingsController = Get.find();
  RxList<ChatGPTMessage> messages = <ChatGPTMessage>[].obs;
  final JsonDecoder _decoder = const JsonDecoder();

  sendMessage(String messageText) {
    ChatGPTMessage message = ChatGPTMessage(content: messageText, isSent: true);

    messages.add(message);

    // ChatGPTMessage message1 = ChatGPTMessage(
    //     content: 'message from chatgpt', isSent: false);
    // messages.add(message1);
    //
    // return;

    var param = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": messageText}
      ],
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    });

    return http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
        body: param,
        headers: {
          "Authorization": "Bearer ${_settingsController.setting.value!.chatGPTKey}",
          'Content-Type': 'application/json'
        }).then((http.Response response) async {
      dynamic data = _decoder.convert(utf8.decode(response.bodyBytes));
      if (data['status'] == 401 && data['data'] == null) {
      } else {
        ChatGPTApiResponse response = ChatGPTApiResponse.fromJson(data);

        ChatGPTMessage message = ChatGPTMessage(
            content: response.data[0]['message']['content'], isSent: false);
        messages.add(message);

        return;
      }
      return null;
    });
  }
}
