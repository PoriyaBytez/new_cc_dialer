import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import '../../../utils/bottonNavBar.dart';
import '../../../utils/settings.dart';
import '../contact/view_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // HomeBloc bloc = HomeBloc();

  Widget appBarTitle = const Text(
    "Contacts",
    style: TextStyle(fontSize: 24, color: Colors.white),
  );
  Icon actionIcon = const Icon(
    Icons.search,
    color: Colors.blue,
    size: 30.0,
  );
  Color color = Colors.indigo;
  bool searching = false;
  bool isloading = false;
  final TextEditingController _cSearch = TextEditingController();

  List<Contact> searchContacts = [];

  Offset? _tapPosition;

  // Contact? c;

  void _onTapDown(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfff0f8ff),
        appBar: PreferredSize(
            preferredSize: const Size(double.infinity, kToolbarHeight / 0.99),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: searching == true ? Container(
                width: 300,
                child: TextField(
                  controller: _cSearch,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    onSearchTextChanged(value);
                    searching = true;
                  },
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          size: 30.0, color: Colors.blue),
                      hintText: "Search Contacts",
                      hintStyle: TextStyle(color: Colors.white)),
                ),
              ) : appBarTitle,
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        Color(0xff1034a6),
                        Color(0xff417dc1),
                        Color(0xffdcdcdc)
                      ]),
                ),
              ),
              actions: <Widget>[
                IconButton(onPressed: (){
                  setState(() {
                    searching = !searching;
                    _cSearch.text = '';
                    searchContacts.clear();
                  });
                }, icon:  Icon(
                  searching ? Icons.clear :  Icons.search,
                  color: searching ? Colors.white : Colors.blue,
                  size: 30.0,
                ),),

                IconButton(onPressed: (){

                }, icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                  size: 30.0,
                ),)
              ],
            )),
        body: isloading
            ? Center(
            child: SizedBox(
              width: 200,
              height: 50,
              child: LiquidLinearProgressIndicator(
                value: 0.65,
                valueColor: const AlwaysStoppedAnimation(Color(0xffdcdcdc)),
                backgroundColor: Colors.white,
                borderColor: Colors.black,
                borderRadius: 15,
                borderWidth: 1.0,
                direction: Axis.horizontal,
                center: const Text("Loading..."),
              ),
            ))
            : CupertinoScrollbar(
          thickness: 6,
          thicknessWhileDragging: 9,
          child: searchContacts.length != 0 || _cSearch.text.isNotEmpty
              ? ListView.builder(
            itemCount: searchContacts.length,
            itemBuilder: (BuildContext context, index) {
              Contact? c = searchContacts.elementAt(index);
              return GestureDetector(
                onTapDown: _onTapDown,
                onLongPress: () {
                  showMenu(
                    context: context,
                    items: [
                      PopupMenuItem(
                        child: TextButton(
                          child: Column(children: const <Widget>[
                            Icon(Icons.phone),
                            Text(
                              "Call",
                              style: TextStyle(fontSize: 16),
                            ),
                          ]),
                          onPressed: () {
                            // bloc.setContact(item);
                            String? phoneNumber =
                            (c.phones.length != 0)
                                ? c.phones.elementAt(0).number
                                : '  ';
                            if (!mounted) return;
                            dest = phoneNumber
                                .replaceAll(' ', '')
                                .replaceAll('+', '00')
                                .toString();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavBar(),
                                ));
                          },
                        ),
                      ),
                    ],
                    position: RelativeRect.fromRect(
                      _tapPosition! & const Size(40, 40),
                      // smaller rect, the touch area
                      // Offset.zero & overlay!.size, // Bigger rect, the entire screen
                      Rect.zero,
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0),
                    leading: CircleAvatar(
                      child: Text(
                        "${c.displayName.substring(0, 1).toUpperCase()}",
                        style: const TextStyle(
                            fontSize: 26, color: Colors.white60),
                      ),
                    ),
                    title: Text(
                      "${c.displayName}",
                      style: const TextStyle(fontSize: 17),
                    ),
                    subtitle: (c.phones.length != 0)
                        ? Text(
                      "${c.phones.elementAt(0).number}",
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewPage(c)),
                      );
                    },
                  ),
                ),
              );
            },
          )
              : ListView.builder(
            itemCount: contactsCallScreen.length,
            itemBuilder: (BuildContext context, index) {
              Contact? c = contactsCallScreen.elementAt(index);
              return GestureDetector(
                onTapDown: _onTapDown,
                onLongPress: () {
                  showMenu(
                    context: context,
                    items: [
                      PopupMenuItem(
                        child: TextButton(
                          child: Column(children: const <Widget>[
                            Icon(Icons.phone),
                            Text(
                              "Call",
                              style: TextStyle(fontSize: 16),
                            ),
                          ]),
                          onPressed: () {
                            // bloc.setContact(item);
                            String? phoneNumber =
                            (c.phones.length != 0)
                                ? c.phones.elementAt(0).number
                                : '  ';
                            if (!mounted) return;
                            dest = phoneNumber
                                .replaceAll(' ', '')
                                .replaceAll('+', '00')
                                .toString();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavBar(),
                                ));
                          },
                        ),
                      ),
                    ],
                    position: RelativeRect.fromRect(
                      _tapPosition! & const Size(40, 40),
                      // smaller rect, the touch area
                      // Offset.zero & overlay!.size, // Bigger rect, the entire screen
                      Rect.zero,
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0),
                    leading: CircleAvatar(
                      child: Text(
                        "${c.displayName.substring(0, 1).toUpperCase()}",
                        style: const TextStyle(
                            fontSize: 26, color: Colors.white60),
                      ),
                    ),
                    title: Text(
                      "${c.displayName}",
                      style: const TextStyle(fontSize: 17),
                    ),
                    subtitle: (c.phones.length != 0)
                        ? Text(
                      "${c.phones.elementAt(0).number}",
                    )
                        : null,
                    onTap: () {
                      // bloc.setContact(item);
                      print('item ==> ${c.displayName}');
                      print('item ==> ${c.phones[0]}');
                      print('index ==> ${index}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewPage(c)),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ));
  }

  onSearchTextChanged(String text) async {
    searchContacts.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    contactsCallScreen.forEach((userDetail) {
      if (userDetail.displayName.toLowerCase().contains(text.toLowerCase()) ||
          userDetail.displayName.toUpperCase().contains(text.toUpperCase()))
        searchContacts.add(userDetail);
    });

    setState(() {});
  }
}
