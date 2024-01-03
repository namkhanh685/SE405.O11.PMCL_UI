import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCManager {
  Future<void> getNFCAvailable() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    print(availability);
  }

  Future<String?> startNFCSession() async {
    var tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: "Multiple tags found!",
        iosAlertMessage: "Scan your tag");
    if (tag.type == NFCTagType.iso7816) {
      var response = await FlutterNfcKit.transceive(
          "00A4040007A000DADADADADA00",
          timeout: const Duration(
              seconds:
                  5)); // timeout is still Android-only, persist until next change
      String result = response.substring(response.length - 4);
      if (result == "9000") {
        String data = response.split("9000")[0];
        List<int> listByte = [];

        for (var i = 0; i < data.length; i += 2) {
          listByte.add(int.parse(data.substring(i, i + 2), radix: 16));
        }
        data = utf8.decode(listByte);
        await FlutterNfcKit.finish();
        return data;
      }
    }
    await FlutterNfcKit.finish();
    return null;
  }
}

