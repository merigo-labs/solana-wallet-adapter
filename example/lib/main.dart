/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:solana_common/models/serializable.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';


/// Main
/// ------------------------------------------------------------------------------------------------

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('SolanaWalletAdapter Plugin Example App'),
      ),
      body: const SolanaWalletAdapterApp(),
    )
  ));
}


/// Solana Wallet Adapter
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAdapterApp extends StatefulWidget {
  const SolanaWalletAdapterApp({super.key});
  @override
  State<SolanaWalletAdapterApp> createState() => _SolanaWalletAdapterAppState();
}


/// Solana Wallet Adapter State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletAdapterAppState extends State<SolanaWalletAdapterApp> {
  
  final SolanaWalletAdapter adapter = SolanaWalletAdapter(
    Identity(
      uri: Uri.parse('https://solana.com'),
      icon: Uri.parse('favicon.ico'),
      name: 'My DApp',
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  void _run<T extends Serializable>(Future<T> Function() method) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final T result = await method();
      print('[SolanaWalletAdapter] Result ${result.toJson()}');
      messenger.showSnackBar(SnackBar(content: Text('${result.toJson()}')));
    } catch(error, stackTrace) {
      print('[SolanaWalletAdapter] Error $error');
      messenger.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('$error', style: const TextStyle(color: Colors.white)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 16.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Non-Privileged', style: TextStyle(fontWeight: FontWeight.bold),),
        const SizedBox(height: spacing,),
        Center(
          child: Wrap(
            spacing: spacing,
            children: [
              TextButton(
                onPressed: () => _run(() => adapter.authorize()), 
                child: const Text('Authorize'),
              ),
              TextButton(
                onPressed: () => _run(() => adapter.deauthorize()), 
                child: const Text('Deauthorize'),
              ),
              TextButton(
                onPressed: () => _run(() => adapter.reauthorize()), 
                child: const Text('Reauthorize'),
              ),
              TextButton(
                onPressed: () => _run(() => adapter.reauthorizeOrAuthorize()), 
                child: const Text('Reauthorize or Authorize'),
              ),
              TextButton(
                onPressed: () => _run(() => adapter.getCapabilities()), 
                child: const Text('Get Capabilities'),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing * 2.0,),
        const Text('Privileged', style: TextStyle(fontWeight: FontWeight.bold),),
        const SizedBox(height: spacing,),
        Center(
          child: Wrap(
            spacing: spacing,
            children: [
            ],
          ),
        ),
      ],
    );
  }
}
