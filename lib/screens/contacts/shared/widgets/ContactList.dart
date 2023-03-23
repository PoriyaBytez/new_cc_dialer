// import 'package:contacts_service/contacts_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
//
// import '../../../../utils/bottonNavBar.dart';
// import '../../../../utils/settings.dart';
// import '../../app_module.dart';
// import '../../app_widget.dart';
// import '../../contact/view_page.dart';
// import '../../home/home_bloc.dart';
// import '../../home/home_module.dart';
// import 'package:flutter/material.dart';
//
// import '../../home/home_page.dart';
// import '../repository/contact_repository.dart';
//
// class ContactList extends StatefulWidget {
//   ContactList({required this.items}) : super();
//
//   List<Map> items;
//
//   @override
//   _ContactListState createState() => _ContactListState();
// }
//
// class _ContactListState extends State<ContactList> {
//   Offset? _tapPosition;
//   HomeBloc? bloc;
//   List<Contact> contactsItems = [];
//   List<Contact> contacts = [];
//   List<Contact> contactsFiltered = [];
//   ContactRepository? contactRepository;
//
//   // final BottomNavigationBar navigationBar = navBarGlobalKey.currentWidget;
//
//   @override
//   void initState() {
//     addAllContactBook();
//
//     // checkContactPermission();
//     bloc = HomeModule.to.getBloc<HomeBloc>();
//     contactRepository = ContactsModule.to.getDependency<ContactRepository>();
//     super.initState();
//   }
//
//   void _onTapDown(TapDownDetails details) {
//     _tapPosition = details.globalPosition;
//   }
//
// //#################################################################################################################
//   String flattenPhoneNumber(String phoneStr) {
//     return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
//       return m[0] == "+" ? "+" : "";
//     });
//   }
//
// //#################################################################################################################
//   getAllContacts() async {
//     contactsItems = await ContactsService.getContacts(withThumbnails: false);
//     if (mounted) {
//       if (!mounted) return;
//       setState(() {
//         contacts=contactsItems;
//       });
//     }
//     // contacts = contactsItems.toList();
//   }
//
// //##################################################################################################################
//   addAllContactBook() {
//     contactRepository?.deleteall(-1).whenComplete(() {
//       contacts.forEach((element) {
//         var _phoneNumber = element.phones!.isNotEmpty
//             ? (element.phones!.elementAt(0).value.toString() == null
//                 ? element.phones!.elementAt(1).value.toString()
//                 : element.phones!.elementAt(0).value.toString())
//             : '00';
//         var _eMail = element.emails!.isNotEmpty
//             ? (element.emails!.elementAt(0).value.toString() == null
//                 ? element.emails!.elementAt(1).value.toString()
//                 : element.emails!.elementAt(0).value.toString())
//             : 'No Email';
//
//         contactRepository!.insert({
//           'name': element.displayName.toString() != null
//               ? element.displayName.toString()
//               : 'No Name',
//           'nickName': element.givenName.toString() != null
//               ? element.givenName.toString()
//               : 'No Nickname ',
//           'work': element.phones!.isNotEmpty
//               ? (element.phones!.length >= 2
//                   ? element.phones!.elementAt(1).value.toString() == null
//                       ? element.phones!.elementAt(0).value.toString()
//                       : element.phones!.length == 2
//                           ? element.phones!.elementAt(1).value.toString()
//                           : 'No Other Contact'
//                   : 'No Other Contact')
//               : '00',
//           'phoneNumber':
//               element.phones!.isNotEmpty ? _phoneNumber : 'No Phone Number',
//           'email': element.emails!.isNotEmpty ? _eMail : 'No Email',
//           'webSite': 'No Website',
//           'favorite': '0',
//           'created': DateTime.now().toString()
//         });
//         bloc!.getListContact();
//       });
//     });
//   }
//
// //##################################################################################################################
// //##################################################################################################################
//   checkContactPermission() async {
//     getAllContacts();
//     addAllContactBook();
//   }
//
// //##################################################################################################################
//   Column column(context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         SizedBox(
//           height: 100,
//           width: 100,
//           child: Image.asset(
//             'lib/assets/images/contact.png',
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 105),
//         const Center(
//           child: Text(
//             'TAP REFRESH ICON TO LOAD CONTACTS',
//             style: TextStyle(
//               color: Colors.indigo,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(height: 35),
//         IconButton(
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.black,
//               size: 50.0,
//             ),
//             onPressed: () {
//               checkContactPermission();
//             }),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     if (widget.items.isEmpty) {
//       checkContactPermission();
//       // return column(context);
//       return Center(
//           child: SizedBox(
//         width: 200,
//         height: 50,
//         child: LiquidLinearProgressIndicator(
//           value: 0.65,
//           valueColor: const AlwaysStoppedAnimation(Color(0xffdcdcdc)),
//           backgroundColor: Colors.white,
//           borderColor: Colors.black,
//           borderRadius: 15,
//           borderWidth: 1.0,
//           direction: Axis.horizontal,
//           center: const Text("Loading..."),
//         ),
//       ));
//     }
//
//     return CupertinoScrollbar(
//       thickness: 6,
//       thicknessWhileDragging: 9,
//       child: ListView.builder(
//         itemCount: widget.items.length,
//         itemBuilder: (BuildContext context, int index) {
//           print("widget.items.length ==> ${widget.items.length}");
//           // Map item = bloc!.getListContact()[index];
//           Map item = widget.items[index];
//           return GestureDetector(
//             onTapDown: _onTapDown,
//             onLongPress: () {
//               showMenu(
//                 context: context,
//                 items: [
//                   PopupMenuItem(
//                     child: TextButton(
//                       child: Column(children: const <Widget>[
//                         Icon(Icons.phone),
//                         Text(
//                           "Call",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ]),
//                       onPressed: () {
//                         bloc!.setContact(item);
//                         if (!mounted) return;
//                         dest = item['phoneNumber']
//                             .replaceAll(' ', '')
//                             .replaceAll('+', '00')
//                             .toString();
//
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BottomNavBar(),
//                             ));
//                       },
//                     ),
//                   ),
//                 ],
//                 position: RelativeRect.fromRect(
//                   _tapPosition! & const Size(40, 40),
//                   // smaller rect, the touch area
//                   // Offset.zero & overlay!.size, // Bigger rect, the entire screen
//                   Rect.zero,
//                 ),
//               );
//             },
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 leading: CircleAvatar(
//                   child: Text(
//                     item['name'].substring(0, 1).toUpperCase(),
//                     style: const TextStyle(fontSize: 26, color: Colors.white60),
//                   ),
//                 ),
//                 title: Text(
//                   item['name'],
//                   style: const TextStyle(fontSize: 17),
//                 ),
//                 subtitle: item['phoneNumber'].toString().isNotEmpty
//                     ? Text(item['phoneNumber'])
//                     : null,
//                 onTap: () {
//                   bloc!.setContact(item);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ViewPage()),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
