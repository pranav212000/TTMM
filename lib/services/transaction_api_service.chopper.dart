// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$TransactionApiService extends TransactionApiService {
  _$TransactionApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = TransactionApiService;

  @override
  Future<Response<dynamic>> getTranasaction(String eventId) {
    final $url = '/transaction/';
    final $params = <String, dynamic>{'eventId': eventId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postPayBill(
      String eventId, Map<String, dynamic> body) {
    final $url = '/transaction/payBill';
    final $params = <String, dynamic>{'eventId': eventId};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postPayPerson(
      String eventId, Map<String, dynamic> body) {
    final $url = '/transaction/payPerson';
    final $params = <String, dynamic>{'eventId': eventId};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> allToGets(String eventId) {
    final $url = '/transaction/allToGets';
    final $params = <String, dynamic>{'eventId': eventId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
