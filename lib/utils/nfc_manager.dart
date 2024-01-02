import 'package:nfc_manager/nfc_manager.dart';

class NFCManager {
  static final NfcManager nfcInstance = NfcManager.instance;
  Future<void> getNFCAvailable() async {
    bool isAvailable = await nfcInstance.isAvailable();
    print(isAvailable);
  }

  Future<String> startNFCSession() async {
    var data = "";
    await nfcInstance.startSession(
      onDiscovered: (tag) async {
        final ndefTag = Ndef.from(tag);
        if (ndefTag == null) throw Exception('No NDEF tag');
        data = (await ndefTag.read()) as String;
        print(data);
      },
      onError: (dynamic error) async {
        print(error.message);
      },
    );
    return data;
  }
}
