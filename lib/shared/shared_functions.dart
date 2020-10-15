
  import 'package:upi_india/upi_india.dart';

Future<UpiResponse> initiateTransaction(String app, String upiId, String receiverName, double amount, String note) async {
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