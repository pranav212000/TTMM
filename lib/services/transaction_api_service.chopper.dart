// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$TransactionApiService extends TransactionApiService {
  _$TransactionApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = TransactionApiService;

  Future<Response> postPayBill(String eventId, Map<String, dynamic> body) {
    final $url = '/transaction/payBill';
    final Map<String, dynamic> $params = {'eventId': eventId};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> postPayPerson(String eventId, Map<String, dynamic> body) {
    final $url = '/transaction/payPerson';
    final Map<String, dynamic> $params = {'eventId': eventId};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> allToGets(String eventId) {
    final $url = '/transaction/allToGets';
    final Map<String, dynamic> $params = {'eventId': eventId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
