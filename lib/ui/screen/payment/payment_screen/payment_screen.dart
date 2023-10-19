import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:nfc_e_wallet/data/preferences.dart';
import 'package:nfc_e_wallet/main.dart';
import 'package:nfc_e_wallet/ui/screen/payment/payment_screen/bloc/payment_screen_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../style/color.dart';
import '../payment_confirm/payment_confirm.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentScreenBloc(),
      child: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget{
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  late PaymentScreenBloc paymentScreenBloc;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = jsonDecode(prefs.getString(Preferences.user)!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScreenBloc, PaymentScreenState>(
      builder: (context, state) {
        int themeIndex = state.themeIndex;
        String message = state.message;
        String amount = state.amount;
        amountController.text = amount;
        messageController.text = message;

        Decoration themeDecoration = _buildThemeDecoration(themeIndex);

        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              leading: BackButton(color: onPrimary),
              backgroundColor: primary,
            ),
            body: Column(
              children: [
                AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.height > 600 ? 390 / 600 : 350/455,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: themeDecoration,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints.maxHeight;
                        final suggestIconHeight = MediaQuery.of(context).size.height > 600 ? height * 14 / 250 : height * 14 / 275;

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 26 / 5,
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10.0),
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: CircleAvatar(
                                            child: Image.asset(
                                                'assets/images/icons/avatar.png'),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(user["full_name"],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ],
                                      )
                                    ]),
                              ),
                              AspectRatio(
                                aspectRatio: 69 / 10,
                                child: TextFormField(
                                  controller: amountController,
                                  onChanged: (value) {
                                    context.read<PaymentScreenBloc>().add(ChangeAmountEvent(value));
                                  },
                                  decoration: InputDecoration(
                                    hoverColor: primaryContainer,
                                    focusColor: primary,
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.search),
                                    border: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    hintText: "Nhập mệnh giá",
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        context.read<PaymentScreenBloc>().add(const ChangeAmountEvent(''));
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  buildSuggestButton(context, suggestIconHeight, '100.000'),
                                  buildSuggestButton(context,
                                      suggestIconHeight, '1.000.000'),
                                  buildSuggestButton(context,
                                      suggestIconHeight, '10.000.000')
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              AspectRatio(
                                aspectRatio: 344 / 35,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: messageController,
                                        onChanged: (value) {
                                          context.read<PaymentScreenBloc>().add(ChangeMessageEvent(value));
                                        },
                                        decoration: InputDecoration(
                                          hoverColor: primaryContainer,
                                          focusColor: primary,
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(Icons.message),
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          hintText: 'Bạn nhớ nhập lời nhắn nhé',
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildRoundButton(suggestIconHeight, 'Chuyển tiền', () {
                                    context.read<PaymentScreenBloc>().add(ChangeMessageEvent('Chuyển tiền'));
                                  }),
                                  buildRoundButton(suggestIconHeight, 'Chúc zui', () {
                                    context.read<PaymentScreenBloc>().add(ChangeMessageEvent('Chúc zui'));
                                  }),
                                  buildRoundButton(suggestIconHeight, 'Hết nợ hết nghĩa!', () {
                                    context.read<PaymentScreenBloc>().add(ChangeMessageEvent('Hết nợ hết nghĩa!'));
                                  }),
                                ],
                              ),
                            ]);
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final height = constraints.maxHeight;

                    final themeButtonHeight = (height - 35) / 2;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildThemeButton(Colors.grey.shade300, themeButtonHeight, Visibility(
                                  visible: themeIndex == 0,
                                  child: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: green,
                                  )), () {
                                context.read<PaymentScreenBloc>().add(ChangeThemeEvent(0));
                              }),
                              const SizedBox(width: 5),
                              buildThemeButton(Colors.blue, themeButtonHeight,
                                  Visibility(
                                      visible: themeIndex == 1,
                                      child: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: green,
                                      )), () {
                                    context.read<PaymentScreenBloc>().add(ChangeThemeEvent(1));
                                  }),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: themeButtonHeight,
                          child: AspectRatio(
                              aspectRatio: 270 / 48,
                              child: Container(
                                  margin: const EdgeInsets.all(0),
                                  decoration: const BoxDecoration(
                                      color: green,
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                                  child: TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(30))),
                                          builder: (BuildContext context) {
                                            return const PaymentConfirm(receiver: "Hiep", phoneNumber: "0827989868", amount: "1.000.000",); //const PaymentConfirm();
                                          });
                                    },
                                    child: const Text(
                                      'Tiếp tục',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ))),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Decoration _buildThemeDecoration(int themeIndex) {
    switch (themeIndex) {
      case 0:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              onPrimary,
              Color(0xFFE0E0E0),
            ],
          ),
        );
      case 1:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryContainer,
              primary,
            ],
          ),
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              onPrimary,
              Color(0xFFE0E0E0),
            ],
          ),
        );
    }
  }

  Widget buildThemeButton(
      Color color,
      double height,
      Widget child,
      void Function() onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: height,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: child
      ),
    );
  }

  Container buildSuggestButton(BuildContext context, double suggestIconHeight, String text) {
    text = '$textđ';
    return buildRoundButton(suggestIconHeight, text, () {
      context.read<PaymentScreenBloc>().add(ChangeAmountEvent(text));
    });
  }

  Container buildRoundButton(
      double suggestIconHeight, String text, void Function()? onTap) {
    return Container(
      height: suggestIconHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Center(
          child: TextButton(
            onPressed: onTap,
            child: Text(text, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}