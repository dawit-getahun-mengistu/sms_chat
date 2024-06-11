import 'package:flutter/material.dart';
import 'package:sms_mms_app/screens/chat_list_screen.dart';
import 'package:telephony/telephony.dart';

class SendNewMessageScreen extends StatefulWidget {
  final List<String> recipients = [];
  SendNewMessageScreen({super.key});

  @override
  State<SendNewMessageScreen> createState() => _SendNewMessageScreenState();
}

class _SendNewMessageScreenState extends State<SendNewMessageScreen> {
  final newRecipientController = TextEditingController();
  final messageController = TextEditingController();
  final List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getConversationHistoryById("2"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.black12,
                  flexibleSpace: SafeArea(
                      child: Container(
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(children: <Widget>[
                            IconButton(
                              onPressed: () {
                                // Navigator.pop(context);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ChatsListScreen();
                                }));
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                  Text(
                                    "Send a New Message",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  // Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                                ]))
                          ])))),
              body: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      children: [
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(children: [
                                for (var recipient in widget.recipients)
                                  Chip(
                                      label: Text(recipient),
                                      deleteIcon:
                                          Icon(Icons.highlight_remove_rounded),
                                      // deleteIconColor: Colors.red,
                                      onDeleted: () {
                                        setState(() {
                                          widget.recipients.removeAt(widget
                                              .recipients
                                              .indexOf(recipient));
                                        });
                                      }),
                              ]),
                            )),
                        const Spacer(),
                        IconButton(
                            alignment: Alignment.topRight,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        scrollable: true,
                                        title: Text("Add new recipient"),
                                        content: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, left: 8, right: 8),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller:
                                                      newRecipientController,
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      newRecipientController
                                                          .text = value;
                                                    });
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              "Enter phone number",
                                                          icon: Icon(Icons
                                                              .account_box)),
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        widget.recipients.add(
                                                            newRecipientController
                                                                .text);
                                                        newRecipientController
                                                            .text = "";
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('dialog');
                                                      });
                                                    },
                                                    child: const Text(
                                                        "Add Recipient"))
                                              ]),
                                        ));
                                  });
                            },
                            icon: const Icon(Icons.add))
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: messages.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green[200],
                              ),
                              child: Text(
                                messages[index],
                                style: const TextStyle(fontSize: 15),
                              )),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                      height: 60,
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              onSubmitted: (value) {
                                messageController.text = value;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Write message...",
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _sendMessage(
                                    widget.recipients, messageController.text);
                                messages.add(messageController.text);
                                messageController.text = "";
                              });
                            },
                            backgroundColor: Colors.blue,
                            elevation: 0,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  _sendMessage(List<String> recipients, String message) async {
    final Telephony telephony = Telephony.instance;
    for (var recepient in recipients) {
      telephony.sendSms(to: recepient, message: message);
    }
  }

  Future<List<SmsMessage>> getInboxById(String id) async {
    ///each conversation has a thread id. this will filter it by that
    final Telephony telephony = Telephony.instance;
    return await telephony.getInboxSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
        SmsColumn.THREAD_ID,
        SmsColumn.ID
      ],
      filter: SmsFilter.where(SmsColumn.THREAD_ID).equals(id),
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        OrderBy(SmsColumn.BODY)
      ],
    );
  }

  Future<List<SmsMessage>> getSentById(String id) async {
    ///each conversation has a thread id. this will filter it by that
    final Telephony telephony = Telephony.instance;
    return await telephony.getSentSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
        SmsColumn.THREAD_ID,
        SmsColumn.ID
      ],
      filter: SmsFilter.where(SmsColumn.THREAD_ID).equals(id),
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        OrderBy(SmsColumn.BODY)
      ],
    );
  }

  getConversationHistoryById(String id) async {
    List<SmsMessage> inbox = await getInboxById(id);
    List<SmsMessage> sent = await getSentById(id);
    List<SmsMessage> history = [...inbox, ...sent];
    history.sort((a, b) => a.date!.compareTo(b.date!));
    return history;
  }
}
