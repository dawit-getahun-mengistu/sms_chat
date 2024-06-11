import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sms_mms_app/screens/chat_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(MaterialApp(
    title: "SMS App",
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Stream<Map<String, dynamic>> streamMessages() async* {
    print("stream called");
    final data = await getData();
    yield* Stream.periodic(const Duration(seconds: 1), (count) {
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //     stream: streamMessages(),
    //     builder: (context, snapshot) {
    //       print("data: ${snapshot.data}");
    //       if (snapshot.hasData) {
    //         final data = snapshot.data as Map<String, dynamic>;
    //         print("here");
    //         return ChatsListScreen(
    //           conversations: data['conversations'],
    //           addressBook: data['addresses'],
    //         );
    //       } else {
    //         return const CircularProgressIndicator();
    //       }
    //     });
    return const ChatsListScreen();
  }
}

sendMessage() async {
  final Telephony telephony = Telephony.instance;
  telephony.sendSms(to: "1234567890", message: "May God be with you!");
}

_sendMessage(List<String> recipients, String message) async {
  final Telephony telephony = Telephony.instance;
  for (var recepient in recipients) {
    telephony.sendSms(to: recepient, message: message);
  }
}

Future<List<SmsMessage>> getInbox() async {
  final Telephony telephony = Telephony.instance;
  return await telephony.getInboxSms(
    columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
      SmsColumn.THREAD_ID,
      SmsColumn.ID
    ],
    sortOrder: [
      OrderBy(SmsColumn.DATE, sort: Sort.DESC),
      OrderBy(SmsColumn.BODY)
    ],
  );
}

Future<List<SmsMessage>> getSent() async {
  final Telephony telephony = Telephony.instance;
  return await telephony.getSentSms(
    columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
      SmsColumn.THREAD_ID,
      SmsColumn.ID
    ],
    sortOrder: [
      OrderBy(SmsColumn.DATE, sort: Sort.DESC),
      OrderBy(SmsColumn.BODY)
    ],
  );
}

Future<List<SmsConversation>> getConversation() async {
  final Telephony telephony = Telephony.instance;
  return await telephony.getConversations();
}

Future<Map<String, String>> getAddresses() async {
  print('1');
  final messages = await getConversationHistory();
  print('2');
  Map<String, String> addressbook = {};
  print('3');
  for (var message in messages) {
    print('threadId: ${message.threadId}');
    print('message: ${message.address}');
    addressbook['${message.threadId}'] = message.address;
  }
  // print('ret');
  return addressbook;
}

getData() async {
  final conversations = await getConversation();
  print("fetched conversations");
  final addressbook = await getAddresses();
  print("fetched addresses");
  final ret = {"conversations": conversations, "addresses": addressbook};
  return ret;
}

// Map<String, List<SmsMessage>> getMessageHistory() async {
//   ///map of the other party's phone number, and a list of all texts

//   List<SmsMessage> inbox = await getInbox();
//   List<SmsMessage> sent = await getSent();
// }

getConversationHistory() async {
  List<SmsMessage> inbox = await getInbox();
  List<SmsMessage> sent = await getSent();
  List<SmsMessage> history = [...inbox, ...sent];
  history.sort((a, b) => a.date!.compareTo(b.date!));
  return history;
}
