// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$FirebaseApiService extends FirebaseApiService {
  _$FirebaseApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = FirebaseApiService;

  @override
  Future<Response<dynamic>> storeToken(Map<String, dynamic> body) {
    final $url = '/firebase/storeToken';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> sendCashConfirmation(Map<String, dynamic> body) {
    final $url = '/firebase/sendCashConfirmation';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> sendNotGotCash(String paymentId) {
    final $url = '/firebase/notGotCash';
    final $params = <String, dynamic>{'paymentId': paymentId};
    final $request = Request('POST', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
