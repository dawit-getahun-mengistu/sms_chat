import 'package:flutter/material.dart';
import 'package:sms_mms_app/chat_item.dart';
import 'package:sms_mms_app/screens/message_compose_screen.dart';
import 'package:telephony/telephony.dart';

class ChatsListScreen extends StatefulWidget {
  ///first screen that launches. shows a list of all conversations

  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  Stream<Map<String, dynamic>> streamMessages() async* {
    print("stream called");
    final data = await getData();
    yield* Stream.periodic(const Duration(microseconds: 1), (count) {
      return data;
    });
  }

  @override
  void didUpdateWidget(covariant ChatsListScreen oldWidget) {
    setState(() {
      print("pointless");
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streamMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
          }
          final conversations = snapshot.data!['conversations'];
          final addressBook = snapshot.data!['addresses'];
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Messages"),
              // foregroundColor: Colors.white,
              // backgroundColor: Colors.black,
            ),
            floatingActionButton: SizedBox(
              width: 150,
              child: FloatingActionButton(
                backgroundColor: Colors.indigo,
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SendNewMessageScreen();
                  }));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Compose"),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.add),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView.builder(
                      addAutomaticKeepAlives: true,
                      itemCount: conversations.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // print("index: $index");
                        return Conversation(
                          name:
                              "${addressBook['${conversations[index].threadId}']}",
                          snippet: conversations[index].snippet ?? "",
                          threadId: conversations[index].threadId as int,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
        SmsColumn.ID,
        SmsColumn.TYPE,
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
        SmsColumn.ID,
        SmsColumn.TYPE,
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

  getAddressFromThreadId(String id) async {
    String addressId = (await getInboxById(id))[0].address ?? "";
  }

  getData() async {
    final conversations = await getConversation();
    print("fetched conversations");
    final addressbook = await getAddresses();
    print("fetched addresses");
    final ret = {"conversations": conversations, "addresses": addressbook};
    return ret;
  }

  Future<List<SmsConversation>> getConversation() async {
    final Telephony telephony = Telephony.instance;
    return await telephony.getConversations(
      sortOrder: [OrderBy(ConversationColumn.THREAD_ID, sort: Sort.DESC)]
    );
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

  getConversationHistory() async {
    List<SmsMessage> inbox = await getInbox();
    List<SmsMessage> sent = await getSent();
    List<SmsMessage> history = [...inbox, ...sent];
    history.sort((a, b) => a.date!.compareTo(b.date!));
    return history;
  }

  Future<List<SmsMessage>> getInbox() async {
    final Telephony telephony = Telephony.instance;
    return await telephony.getInboxSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
        SmsColumn.THREAD_ID,
        SmsColumn.ID,
        SmsColumn.TYPE,
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
        SmsColumn.ID,
        SmsColumn.TYPE,
      ],
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        OrderBy(SmsColumn.BODY)
      ],
    );
  }
}
