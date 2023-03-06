/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_common/config/cluster.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';


/// Main
/// ------------------------------------------------------------------------------------------------

void main() {
  runApp(const ExampleApp());
}


/// Example App
/// ------------------------------------------------------------------------------------------------

class ExampleApp extends StatefulWidget {
  
  const ExampleApp({
    super.key,
  });

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}


/// Example App State
/// ------------------------------------------------------------------------------------------------

class _ExampleAppState extends State<ExampleApp> {

  static final Cluster cluster = Cluster.http('192.168.0.10', port: 8899);

  final SolanaWalletAdapter adapter = SolanaWalletAdapter(
    AppIdentity(
      uri: Uri.https('merigo.com'),
      icon: Uri.parse('favicon.png'),
      name: 'Example App',
    ),
    cluster: cluster,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin Example App'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () async {
              try {
                print('AUTHORIZING...');
                final r = await adapter.authorize();
                print('AUTHORIZED... ${r.toJson()}');
              } catch (error, stackTrace) {
                print('ERROR $error');
                print('STACK $stackTrace');
              }
            },
            child: const Text('Authorize X'),
          ),
        ),
      ),
    );
  }
}