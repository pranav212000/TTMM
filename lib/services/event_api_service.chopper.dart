// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$EventApiService extends EventApiService {
  _$EventApiService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = EventApiService;

  Future<Response> addEvent(
      String groupId, String split, Map<String, dynamic> body) {
    final $url = '/event/addEvent';
    final Map<String, dynamic> $params = {'groupId': groupId, 'split': split};
    final $body = body;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getEvent(String eventId) {
    final $url = '/event/';
    final Map<String, dynamic> $params = {'eventId': eventId};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getEvents(Map<String, dynamic> body) {
    final $url = '/event/multiple';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> addOrder(String eventId, Map<String, dynamic> body) {
    final $url = '/event/${eventId}/addOrder';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  Future<Response> getOrders(String eventId) {
    final $url = '/event/${eventId}/orders';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
