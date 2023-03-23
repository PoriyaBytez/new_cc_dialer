// import 'dart:convert';
// import 'package:nex_dialer_pro/utils/settings.dart';
// import 'package:requests/requests.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';

// //#################################################################################################################################

// getTarrif() async {
//   String _myTarrif;
//   var conStatus = await DataConnectionChecker().hasConnection;
//   if (conStatus) {
//     var result = await Requests.post(taffifURL,
//         headers: {"Content-Type": "application/json"},
//         body: {
//           "username": sipUsername,
//           "prefix": textController.text.replaceFirst('00', '').toString()
        
//         },
//         bodyEncoding: RequestBodyEncoding.JSON,
//         timeoutSeconds: 3000);
 

//     if (result.success) {
//       if ((json.decode(result.content()).containsKey("payload"))) {
//         var _value = (json.decode(result.content())['payload'].toString());
//         _myTarrif = '\$ ' + _value + '/min';
//         if (_value.contains(' ')) {
//           _myTarrif = '\$ ' + _value.substring(0, _value.length - 3) + '/min';
//           return _myTarrif.toString();
//         }
//       }

//     } else {
      
//     }
//   }
// }

// //#################################################################################################################################
