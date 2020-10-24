// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$EventApiService extends EventApiService {
  _$EventApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = EventApiService;

  @override
  Future<Response<dynamic>> addEvent(
      String groupId, String split, Map<String, dynamic> body) {
    final $url = '/event/addEvent';
    final $params = <String, dynamic>{'groupId': groupId, 'split': split};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getEvent(String eventId) {
    final $url = '/event/';
    final $params = <String, dynamic>{'eventId': eventId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getEvents(Map<String, dynamic> body) {
    final $url = '/event/multiple';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addOrder(
      String eventId, Map<String, dynamic> body) {
    final $url = '/event/$eventId/addOrder';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getOrders(String eventId) {
    final $url = '/event/$eventId/orders';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
