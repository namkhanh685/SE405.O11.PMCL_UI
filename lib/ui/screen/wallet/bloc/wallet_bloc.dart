import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:nfc_e_wallet/data/preferences.dart';
import 'package:nfc_e_wallet/data/repositories/user_repo.dart';
import 'package:nfc_e_wallet/data/repositories/wallet_repo.dart';
import 'package:nfc_e_wallet/main.dart';

import '../../../../data/model/wallet.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletState()) {
    on<InitWalletEvent>((event, emit) async {
      var walletRepo = GetIt.instance.get<WalletRepo>();
      late final user;
      if (prefs.getString(Preferences.user) != null) {
        user = jsonDecode(prefs.getString(Preferences.user)!);
      }
      final listWalletResponse = await walletRepo.getListWallet(user["id"].toString());
      user["wallets"] = listWalletResponse;
      listWallet.clear();
      for (var wallet in listWalletResponse) {
        listWallet.add(Wallet.fromJson(wallet));
        if (wallet["type"] == "DefaultWallet") {
          defaultWallet = Wallet.fromJson(wallet);
        }
      }
      emit(WalletInitialState().copyWith(listWallet: listWallet));
    });
    on<CreateWalletEvent>(((event, emit) async {
      var walletRepo = GetIt.instance.get<WalletRepo>();
      try {
        final wallet = await walletRepo.createWallet(
            event.userId, event.name, event.type, event.cardNumber);
        listWallet.add(wallet!);
        emit(WalletCreatedState(wallet));
      } catch (exception) {
        if (exception is DioException) {
          print(exception.response!.data);
        }
        print("Create wallet failed");
      }
    }));
  }
}
