import 'package:chopper/chopper.dart';
import 'package:ttmm/shared/constants.dart';

part 'order_api_service.chopper.dart';

@ChopperApi(baseUrl: '/order')
abstract class OrderApiService extends ChopperService {
  @Delete(path: '/deleteOrder')
  Future<Response> deleteOrder(@Query('orderId') String orderId);

  @Put(path: 'updateOrder')
  Future<Response> updateOrder(@Query('orderId') String orderId, @Body() body);

  static OrderApiService create() {
    final client = ChopperClient(
        baseUrl: DB_URL,
        services: [_$OrderApiService()],
        converter: JsonConverter(),
        interceptors: [HttpLoggingInterceptor()]);
    return _$OrderApiService(client);
  }
}
