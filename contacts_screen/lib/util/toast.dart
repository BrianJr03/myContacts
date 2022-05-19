import '../theme/colors_plus.dart';

import 'package:fluttertoast/fluttertoast.dart';

class ToastedPlus {
  /// Shows toast message to user.
 static  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: ColorsPlus.secondaryColor,
        textColor: ColorsPlus.primaryColor,
        fontSize: 16.0);
  }
}