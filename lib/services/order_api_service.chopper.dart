// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$OrderApiService extends OrderApiService {
  _$OrderApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = OrderApiService;

  Future<Response> deleteOrder(String orderId) {
    final $url = '/order/deleteOrder';
    final Map<String, dynamic> $params = {'orderId': orderId};
    final $request =
        Request('DELETE', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
