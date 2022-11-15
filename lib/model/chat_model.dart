import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  String id;
  String group = '';
  String message;
  String timestamp;
  String diraction = 'send'; //send receive
  String from; // peerId
  String to = '';
  String reply = '';
  String type;
  String deliveryStatus;
  String replyText = '';
  String textId;
  String url = '';

  ChatModel(
      {this.id,
      this.group,
      this.message,
      this.timestamp,
      this.diraction,
      this.url,
      this.from,
      this.to,
      this.reply,
      this.type,
      this.replyText,
      this.deliveryStatus,
      this.textId});

  ChatModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    url = json['url'];
    timestamp = json['timestamp'];
    group = json['group'];
    from = json['from'];
    to = json['to'];
    reply = json['reply'];
    type = json['type'];
    replyText = json['replyText'];
    deliveryStatus = json['deliveryStatus'];
    textId = json['textId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['url'] = url;
    data['timestamp'] = timestamp;
    data['group'] = group;
    data['from'] = from;
    data['to'] = to;
    data['reply'] = reply;
    data['type'] = type;
    data['deliveryStatus'] = deliveryStatus;
    data['replyText'] = replyText;
    data['textId'] = textId;
    return data;
  }

  @override
  List<Object> get props => [textId];
}
