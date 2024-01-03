import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:nfc_e_wallet/ui/screen/payment/payment_confirm/payment_confirm.dart';
import 'package:nfc_e_wallet/ui/style/color.dart';
import 'package:nfc_e_wallet/utils/nfc_manager.dart';

class NFCTransferScreen extends StatefulWidget {
  const NFCTransferScreen({Key? key}) : super(key: key);

  @override
  _NFCTransferScreen createState() => _NFCTransferScreen();
}

class _NFCTransferScreen extends State<NFCTransferScreen> {
  final TextEditingController amountController = TextEditingController();
  final NFCManager nfcManager = NFCManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Chuyển tiền qua NFC",
              style: TextStyle(fontSize: 26, color: Color(0xFF2196F3))),
        ),
        body: Container(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          value = formatCurrency(value.replaceAll('.', ''));
                          amountController.value = TextEditingValue(
                            text: value,
                            selection:
                                TextSelection.collapsed(offset: value.length),
                          );
                        },
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nhập mệnh giá",
                          suffixText: "đ",
                          prefixIcon:
                              const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: green,
                                    foregroundColor: white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    SmartDialog.show(builder: (context) {
                                      return Container(
                                        height: 100,
                                        width: 250,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                            'Bạn hãy chạm vào điện thoại khác',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      );
                                    });
                                    await nfcManager
                                        .startNFCSession()
                                        .then((result) {
                                          print(result);
                                          if(result!=null){
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                          ),
                                        ),
                                        builder: (BuildContext context) {
                                          return PaymentConfirm(
                                            type: "TRANSFER",
                                            receiverPhoneNumber: result,
                                            amount: amountController.text,
                                          );
                                        },
                                      );}
                                    });
                                  },
                                  child: const Text(
                                    'Tiếp tục',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          )),
                    ]))));
  }

  String formatCurrency(String amount) {
    if (amount.isEmpty) return "";
    final currencyFormat = NumberFormat("#,##0.##");
    return currencyFormat.format(int.parse(amount));
  }
}
