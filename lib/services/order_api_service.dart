import 'package:chopper/chopper.dart';

part 'order_api_service.chopper.dart';

@ChopperApi(baseUrl: '/order')
abstract class OrderApiService extends ChopperService {


  @Delete(path: '/deleteOrder')
  Future<Response> deleteOrder(@Query('orderId') String orderId);

  static OrderApiService create() {
    final client = ChopperClient(
        baseUrl: 'https://ttmm-pp.herokuapp.com/api',
        services: [_$OrderApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]
        );
    return _$OrderApiService(client);
  }
}
