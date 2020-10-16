import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

import 'constants.dart';

Future<UpiResponse> initiateTransaction(String app, String upiId,
    String receiverName, double amount, String note) async {
  UpiIndia upiIndia = UpiIndia();

  return upiIndia.startTransaction(
    app: app, //  I took only the first app from List<UpiIndiaApp> app.
    receiverUpiId: upiId, // Make Sure to change this UPI Id
    receiverName: receiverName,
    transactionRefId: 'testId',
    // TODO add a valid transaction note
    transactionNote: note,
    amount: amount,
  );
}

String getUpiAppName(String app) {
  switch (app) {
    case UpiApp.GooglePay:
      return "Google Pay";
      break;
    case UpiApp.BHIMUPI:
      return "BHIM UPI";
      break;
    case UpiApp.FreeChargeUPI:
      return "Free Charge UPI";
      break;
    case UpiApp.IMobileICICI:
      return "IMobileICICI";
      break;
    case UpiApp.MiPay:
      return "Mi Pay";
      break;
    case UpiApp.MobikwikUPI:
      return "Mobikwik UPI";
      break;
    case UpiApp.MyAirtelUPI:
      return "My Airtel UPI";
      break;
    case UpiApp.PayTM:
      return "PayTM";
      break;
    case UpiApp.PhonePe:
      return "PhonePe";
      break;
    case UpiApp.SBIPay:
      return "SBI Pay";
      break;
    case UpiApp.TrueCallerUPI:
      return "TrueCaller UPI";
      break;
    case UpiApp.AmazonPay:
      return "Amazon Pay";
      break;
    case "com.whatsapp":
      return "WhatsApp";
      break;

    default:
      return app;
  }
}

displayUpiError(GlobalKey<ScaffoldState> _scaffoldKey, String error) {
  switch (error) {
    case UpiError.APP_NOT_INSTALLED:
      print("Requested app not installed on device");
      showSnackbar(_scaffoldKey, "Requested app not installed on device");
      break;
    case UpiError.INVALID_PARAMETERS:
      print("Requested app cannot handle the transaction");
      showSnackbar(_scaffoldKey, "Requested app cannot handle the transaction");

      break;
    case UpiError.NULL_RESPONSE:
      print("requested app didn't returned any response");
      showSnackbar(_scaffoldKey, "Requested app didn't returned any response");

      break;
    case UpiError.USER_CANCELLED:
      print("You cancelled the transaction");
      showSnackbar(_scaffoldKey, "You cancelled the transaction");
      break;
  }
}
