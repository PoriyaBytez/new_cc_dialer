
import 'package:permission_handler/permission_handler.dart';

class PermissionService{

     Future<bool> _requestPermission() async {
       var result = await [Permission.contacts, Permission.microphone, Permission.camera].request();
       if (result[Permission.contacts] == PermissionStatus.granted
                  && result[Permission.microphone] == PermissionStatus.granted
                  && result[Permission.camera] == PermissionStatus.granted)
                  {
                    return true;
                  }
            return false;
     }

     Future<bool> _requestPermissionContacts() async {
       var result = await Permission.contacts.request();

       if (result == PermissionStatus.granted)
                  {
                    return true;
                  }
            return false;
     }

     Future<bool> requestPermission({Function? onPermissionDenied}) async {
       var granted = await _requestPermission();
       if (!granted) {
         onPermissionDenied!();
       }
       return granted;
     }

         Future<bool> requestPermissionContacts({Function? onPermissionDenied}) async {
       var granted = await _requestPermissionContacts();
       if (!granted) {
         onPermissionDenied!();
       }
       return granted;
     }

     Future<bool> hasContactPermission() async {
       return hasPermission(Permission.phone);
     }

     Future<bool> hasPermission(Permission permission) async {
       var permissionStatus = await permission.status;
       return permissionStatus == PermissionStatus.granted;
     }
   }  