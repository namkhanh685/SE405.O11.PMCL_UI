import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:nfc_e_wallet/data/model/transaction.dart';
import 'package:nfc_e_wallet/data/repositories/transaction_repo.dart';
import 'package:nfc_e_wallet/l10n/l10n.dart';
import 'package:nfc_e_wallet/ui/screen/otp/bloc/otp_bloc.dart';
import 'package:nfc_e_wallet/ui/screen/payment/payment_success/payment_success_screen.dart';
import 'package:nfc_e_wallet/ui/screen/root/root_screen.dart';
import 'package:nfc_e_wallet/utils/toast_helper.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rxdart/rxdart.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.phoneNumber, this.url});
  final String phoneNumber;
  final String? url;
  @override
  OTPScreenState createState() =>
      OTPScreenState(phoneNumber: phoneNumber, url: url);
}

class OTPScreenState extends State<OTPScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  final String phoneNumber;
  String? url;
  OTPScreenState({Key? key, required this.phoneNumber, this.url});

  final _otpBloc = OtpBloc();
  final _otpController = TextEditingController();
  final _otpStreamController = BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _otpBloc,
      child: BlocListener<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpSuccess) {
              if (state.type == "REGISTER") {
                ToastHelper.showToast(L10n.of(context).verifySuccess,
                    status: ToastStatus.success);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RootApp()),
                );
              } else if (state.type == "TRANSFER_TRANSACTION" ||
                  state.type == "TRANSACTION") {
                final transaction = Transaction.fromJson(state.data);
                ToastHelper.showToast(L10n.of(context).verifySuccess,
                    status: ToastStatus.success);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentSuccessScreen(
                            transaction: transaction,
                          )),
                );
              }
            } else if (state is OtpFailure) {
              ToastHelper.showToast(
                  "${L10n.of(context).verifySuccess}: ${state.error}",
                  status: ToastStatus.failure);
            }
          },
          child: url == null ? buildOTPScreen() : buildWebView()),
    );
  }

  Widget buildOTPScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Enter OTP code",
            style: TextStyle(fontSize: 26, color: Color(0xFF2196F3))),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Code sent via Phone Number to",
                  style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              Text(phoneNumber,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                controller: _otpController,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _otpStreamController.add(value);
                  });
                },
              ),
              TextButton(
                onPressed: () => context.read<OtpBloc>().add(ResendOtpEvent()),
                child: const Text("Resend Code",
                    style: TextStyle(color: Color(0xFF2196F3))),
              ),
              const SizedBox(height: 30),
              StreamBuilder<String>(
                stream: _otpStreamController.stream,
                builder: (context, snapshot) {
                  bool isValidLength =
                      snapshot.hasData && snapshot.data!.length == 6;
                  return BlocBuilder<OtpBloc, OtpState>(
                    builder: (context, state) {
                      if (state is OtpLoading) {
                        return const CircularProgressIndicator();
                      } else {
                        return ElevatedButton(
                          onPressed: isValidLength
                              ? () {
                                  context.read<OtpBloc>().add(SubmitOtpEvent(
                                      _otpController.text, phoneNumber));
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isValidLength ? Colors.green : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("Continue"),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWebView() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Nạp tiền",
              style: TextStyle(fontSize: 26, color: Color(0xFF2196F3))),
        ),
        body: SafeArea(
            child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url!)),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) async {
            setState(() {
              this.url = url.toString();
            });
            if (url!.queryParameters["status"] == "success") {
              final transactionId = url.queryParameters["transactionId"];
              final transactionRepo = GetIt.instance.get<TransactionRepo>();
              transactionRepo.getSingleTransaction(transactionId!).then(
                (response) {
                  if (response != null) {
                    final transaction = Transaction.fromJson(response);
                    print(transaction.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentSuccessScreen(
                                transaction: transaction,
                              )),
                    );
                  }
                },
              );
            }
          },
        )));
  }
}
