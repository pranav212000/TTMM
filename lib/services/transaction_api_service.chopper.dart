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

  Future<Response> postPaid(String eventId, Map<String, dynamic> body) {
    final $url = '/transaction/paid';
    final Map<String, dynamic> $params = {'eventId': eventId};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
