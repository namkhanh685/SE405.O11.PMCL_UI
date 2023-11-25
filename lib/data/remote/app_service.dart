import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nfc_e_wallet/data/model/response/base_response.dart';
import 'package:nfc_e_wallet/data/model/response/list_model_response.dart';
import 'package:nfc_e_wallet/data/model/response/transaction_response.dart';
import 'package:retrofit/retrofit.dart';
import '../model/response/avatar_file_response.dart';
import '../model/response/login_response.dart';

part 'app_service.g.dart';

@RestApi()
abstract class AppService {
  factory AppService(Dio dio, {String baseUrl}) = _AppService;

  @POST("/login")
  Future<HttpResponse<LoginResponse>> login(@Body() Map<String, dynamic> request);

  @GET("/logout")
  Future<HttpResponse> logout(@Header('Authorization') String token);

  @POST("/register")
  Future<HttpResponse> register(@Body() Map<String, dynamic> request);

  @GET("/verify")
  Future<HttpResponse> verify(@Header('Authorization') String token);

  @POST("/verify_otp")
  Future<HttpResponse> verifyOtp( @Body() Map<String, dynamic> request);

  @POST("/user/change_password/{id}")
  Future<HttpResponse> changePassword(@Path('id') String id, @Body() Map<String, dynamic> request);

  @GET("/user/{id}")
  Future<HttpResponse<BaseResponse>> getUser(@Path('id') String id, @Header('Authorization') String token);

  @GET("/user/get_user_by_phone_number/{phone_number}")
  Future<HttpResponse<BaseResponse>> getUserByPhoneNumber(
      @Path('phone_number') String phoneNumber, @Header('Authorization') String token);

  @POST("/transaction/create_transfer")
  Future<HttpResponse> createTransferTransaction(@Header('Authorization') String token, @Body() Map<String, dynamic> request);

  @POST("/transaction/create_transaction")
  Future<HttpResponse> createTransaction(@Header('Authorization') String token, @Body() Map<String, dynamic> request);

  @GET("/transaction/{user_id}")
  Future<HttpResponse> getListTransaction(@Path('user_id') String id, @Header('Authorization') String token);

  @POST("/wallet/{user_id}")
  Future<HttpResponse> createWallet(@Path('user_id') String id, @Header('Authorization') String token, @Body() Map<String, dynamic> request);

  @GET("/wallet/{user_id}")
  Future<HttpResponse<ListModelResponse>> getWalletByUserId(
      @Path('user_id') String userId, @Header('Authorization') String token);

  @GET("/wallet/get_user_by_wallet/{wallet_id}")
  Future<HttpResponse> getUserByWallet(
      @Path('wallet_id') String walletId, @Header('Authorization') String token);

  @POST("/transaction/{user_id}")
  Future<HttpResponse<ListModelResponse>> getListWallet(@Path('id') String id, @Header('Authorization') String token);

  @PUT("/user/update")
  Future<HttpResponse> updateUser(@Header('Authorization') String token, @Body() Map<String, dynamic> request);
}