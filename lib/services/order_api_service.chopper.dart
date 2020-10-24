// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$OrderApiService extends OrderApiService {
  _$OrderApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = OrderApiService;

  @override
  Future<Response<dynamic>> deleteOrder(String orderId) {
    final $url = '/order/deleteOrder';
    final $params = <String, dynamic>{'orderId': orderId};
    final $request =
        Request('DELETE', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateOrder(String orderId, dynamic body) {
    final $url = '/order/updateOrder';
    final $params = <String, dynamic>{'orderId': orderId};
    final $body = body;
    final $request =
        Request('PUT', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
