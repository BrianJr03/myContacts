import 'package:my_contacts/util/format.dart';

import '/util/toast.dart';
import '/util/dialog.dart';
import '../theme/colors_plus.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class DialerPlus {
  /// Displays a dialer pad.
  static SliverList showDialerPad(
      {required TextEditingController contr, required BuildContext context}) {
    return SliverList(
        delegate: SliverChildListDelegate([
      const SizedBox(height: 15),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton(text: "1", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "2", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "3", contr: contr)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton(text: "4", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "5", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "6", contr: contr)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton(text: "7", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "8", contr: contr),
              const SizedBox(width: 35),
              _dialerButton(text: "9", contr: contr)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              makeCallBTN(
                  context: context,
                  phoneNumber: FormatPlus.formatNormalizedPhoneNumber(
                      phoneNumber: contr.text, isPhoneNormalized: false),
                  contact: contr.text),
              const SizedBox(width: 35),
              _dialerButton(text: "1", contr: contr),
              const SizedBox(width: 35),
              _dialerBackSpace(contr: contr)
            ],
          ),
          const SizedBox(height: 15),
        ],
      )
    ]));
  }

  /// Button that allows a user to make a call to the [phoneNumber].
  static ElevatedButton makeCallBTN(
      {required String phoneNumber,
      required String contact,
      required BuildContext context}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          if (phoneNumber.isNotEmpty) {
            DialogPlus.showDialogPlus(
                content: AutoSizeText.rich(TextSpan(
                    text: 'Call ',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: contact,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsPlus.secondaryColor),
                          children: const [
                            TextSpan(
                              text: ' ?',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            )
                          ])
                    ])),
                context: context,
                onCancelTap: () {},
                onSubmitTap: () {
                  Navigator.pop(context);
                  _makeCall(phoneNumber);
                },
                cancelText: 'Back',
                submitText: 'Call',
                title: const Text("Make Call"));
          } else {
            ToastedPlus.showToast("Phone # is empty");
          }
        },
        child: Icon(Icons.call, color: ColorsPlus.primaryColor));
  }

  /// Button that allows a user to make a SMS to the [phoneNumber].
  static ElevatedButton createSmsBTN(
      {required String phoneNumber, required BuildContext context}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          Navigator.pop(context);
          _createSMS(phoneNumber);
        },
        child: Icon(Icons.sms, color: ColorsPlus.primaryColor));
  }

  /// Button that allows a user to make a email to the [emailAddress].
  static ElevatedButton sendEmailBTN(
      {required String emailAddress, required BuildContext context}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          Navigator.pop(context);
          _sendEmail(emailAddress);
        },
        child: Icon(Icons.email, color: ColorsPlus.primaryColor));
  }

  /// Button used in [showDialerPad].
  static ElevatedButton _dialerButton(
      {required String text, required TextEditingController contr}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          contr.text += text;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Text(text));
  }

  /// Backspace button used in the [showDialerPad].
  static ElevatedButton _dialerBackSpace(
      {required TextEditingController contr}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          var str = contr.text;
          if (str.isNotEmpty) {
            contr.text = str.substring(0, str.length - 1);
          }
        },
        child: const Icon(Icons.backspace));
  }

  /// Calls [contactNumber]. This is a direct call and starts immediately.
  static void _makeCall(String contactNumber) async {
    await FlutterPhoneDirectCaller.callNumber(contactNumber);
  }

  /// Launches the default SMS app, opening the conversation with
  /// [contactNumber].
  static void _createSMS(String contactNumber) {
    launchUrlString('sms:$contactNumber');
  }

  /// Launches the default email app, opening the email to
  /// [emailAddress].
  ///
  /// If the contact's [emailAddress] is not found, a toast warning will be
  /// displayed.
  static void _sendEmail(String emailAddress) {
    if (emailAddress != "N/A") {
      launchUrlString('mailto:$emailAddress');
    }
    ToastedPlus.showToast("No email found for this contact");
  }
}
