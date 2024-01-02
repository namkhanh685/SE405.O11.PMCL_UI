import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:nfc_e_wallet/main.dart';
import 'package:nfc_e_wallet/ui/screen/nfc/nfc_transfer_screen.dart';
import 'package:nfc_e_wallet/ui/style/color.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';

class NFCScreen extends StatefulWidget {
  const NFCScreen({super.key});

  @override
  NFCScreenState createState() => NFCScreenState();
}

class NFCScreenState extends State<NFCScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("NFC",
              style: TextStyle(fontSize: 26, color: Color(0xFF2196F3))),
        ),
        body: Container(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
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
                        child: Center(
                          child: TextButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NFCTransferScreen()),
                              )
                            },
                            child: const Text("Chuyển tiền",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: double.infinity,
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
                        child: Center(
                          child: TextButton(
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
                                      style: TextStyle(color: Colors.white)),
                                );
                              });
                              //INIT NFC
                              const port = 0;
                              // change data to transmit here

                              final data = utf8.encode(user.phone_number);
                              await NfcHce.addApduResponse(port, data);
                            },
                            child: const Text("Nhận tiền",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      )
                    ]))));
  }
}
