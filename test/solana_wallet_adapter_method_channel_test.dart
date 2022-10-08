import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana_wallet_adapter/src/solana_wallet_adapter_method_channel.dart';

void main() {
  MethodChannelSolanaWalletAdapter platform = MethodChannelSolanaWalletAdapter();
  const MethodChannel channel = MethodChannel('solana_wallet_adapter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
