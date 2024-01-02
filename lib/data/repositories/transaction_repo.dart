import 'package:event_bus/event_bus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/transaction.dart';
import '../remote/app_service.dart';
import '../remote/request_factory.dart';

class TransactionRepo {
  final EventBus _eventBus;
  final Logger _logger;
  final SharedPreferences _sharedPreferences;
  final AppService _appService;
  final RequestFactory _requestFactory;

  TransactionRepo(this._logger, this._sharedPreferences, this._appService,
      this._requestFactory, this._eventBus);

  Future<String?> createTransferTransaction(
      String fromUser, String toUser, String amount, String message) async {
    return _appService
        .createTransferTransaction(
            _sharedPreferences.getString('token') ?? "",
            _requestFactory.createTransferTransaction(
                fromUser, toUser, amount, message))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      String? otp;

      if (http.data['message'] == 'OTP SENT') {
        otp = http.data['otp_data'];
      }
      return otp;
    });
  }

  Future<String?> createTransaction(String fromUser, String toUser,
      String amount, String message, String type) async {
    return _appService
        .createTransaction(
            _sharedPreferences.getString('token') ?? "",
            _requestFactory.createTransaction(
                fromUser, toUser, amount, message, type))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      String? otp;

      if (http.data['message'] == 'OTP SENT') {
        otp = http.data['otp_data'];
      }
      return otp;
    });
  }

  Future<List<dynamic>?> getListTransaction(String userId) async {
    return _appService
        .getListTransaction(
            userId, (_sharedPreferences.getString('token') ?? ""))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return [];
      }
      return http.response.data;
    });
  }

  Future<String?> createPaypalDepositTransaction(
      String amount, String message) async {
    return _appService
        .createPaypalDepositTransaction(
            (_sharedPreferences.getString('token') ?? ""),
            _requestFactory.createPaypalDepositTransaction(amount, message))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      return http.data["url"];
    });
  }

  Future<String?> createVNPayTransaction(
      String amount, String message) async {
    return _appService
        .createVNPayTransaction(
            (_sharedPreferences.getString('token') ?? ""),
            _requestFactory.createVNPayTransaction(amount, message))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      return http.data["data"];
    });
  }

  Future<Map<String, dynamic>?> createPaypalWithdrawTransaction(
      String otp, String phoneNumber) async {
    return _appService
        .createPaypalWithdrawTransaction(
            (_sharedPreferences.getString('token') ?? ""),
            _requestFactory.createPaypalWithdrawTransaction(otp, phoneNumber))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      return http.data;
    });
  }

  Future<Map<String,dynamic>?> getSingleTransaction(String id) async {
    return _appService
        .getSingleTransaction(
            id, (_sharedPreferences.getString('token') ?? ""))
        .then((http) async {
      if (http.response.statusCode != 200) {
        return null;
      }
      return http.data;
    });
  }
}
