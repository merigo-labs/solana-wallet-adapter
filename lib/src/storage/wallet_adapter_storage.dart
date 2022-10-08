/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet_adapter_state.dart';
import '../models/account.dart';
import '../models/authorize_result.dart';
import '../utils/types.dart';


/// Wallet Adapter Storage
/// ------------------------------------------------------------------------------------------------

/// Stores the wallet adapter's authorisation state.
class WalletAdapterStorage {

  /// The storage instance.
  static Future<SharedPreferences> get _storage => SharedPreferences.getInstance();

  /// The storage key.
  static const String _key = 'solana_wallet_adapter/wallet_adapter_storage';

  /// The storage value/notifier.
  static final ValueNotifier<WalletAdapterState?> _notifier = ValueNotifier(null);

  /// Add or remote listeners that get notified when the storage data changes.
  Listenable get notifier => _notifier;

  /// Loads the stored data into memory. 
  /// 
  /// This method should be called at the start of your application, before accessing any instance 
  /// properties or methods.
  Future<void> initialize() async {
    final String? value = (await _storage).getString(_key);
    _notifier.value = value != null ? WalletAdapterState.fromJsonString(value) : null;
  }

  /// Disposes of the value [notifier].
  void dispose() => _notifier.dispose();

  /// Registers [listener] to be called when the storage value changes.
  void addListener(final VoidCallback listener) => _notifier.addListener(listener);

  /// Removes a previously registered [listener] to stop being called when the storage value 
  /// changes.
  void remoteListener(final VoidCallback listener) => _notifier.removeListener(listener);

  /// The current state.
  WalletAdapterState? get state => _notifier.value;

  /// Sets [authorizeResult] and [feePayerAccount] as the new state.
  Future<bool> _setState({
    required final AuthorizeResult? authorizeResult,
    required final Account? feePayerAccount,
  }) async {
    Account? feePayer;
    if (authorizeResult != null) {
      if (authorizeResult.accounts.length == 1) {
        feePayer = authorizeResult.accounts.first;
      } else if (authorizeResult.accounts.contains(feePayerAccount)) {
        feePayer = feePayerAccount;
      }
    }
    final WalletAdapterState value = WalletAdapterState(
      authorizeResult: authorizeResult, 
      feePayerAccount: feePayer,
    );
    _notifier.value = value;
    final SharedPreferences prefs = await _storage;
    return prefs.setString(_key, value.toJsonString());
  }

  /// The [state]'s [WalletAdapterState.authorizeResult].
  AuthorizeResult? get authorizeResult => state?.authorizeResult;

  /// Sets the [state]'s [WalletAdapterState.authorizeResult].
  Future<bool> setAuthorizeResult(final AuthorizeResult? authorizeResult) async {
    return _setState(
        authorizeResult: authorizeResult,
        feePayerAccount: state?.feePayerAccount,
    );
  }

  /// Clears the [state]'s [WalletAdapterState.authorizeResult].
  Future<bool> clearAuthorizeResult({ required final AuthToken authToken }) async {
    final AuthToken? token = state?.authorizeResult?.authToken;
    return token == authToken ? setAuthorizeResult(null) : Future.value(true);
  }

  /// The [state]'s [WalletAdapterState.feePayerAccount].
  /// 
  /// Returns `null` if the set account has not been authorized by the wallet endpoint (i.e. the 
  /// account does not exist within the [state]'s [WalletAdapterState.authorizeResult] accounts).
  Account? get feePayerAccount => state?.feePayerAccount;

  /// Sets the [state]'s [WalletAdapterState.feePayerAccount].
  Future<bool> setFeePayerAccount(final Account? feePayerAccount) async {
    return _setState(
      authorizeResult: state?.authorizeResult,
      feePayerAccount: feePayerAccount,
    );
  }

  /// Clears the [state]'s [WalletAdapterState.feePayerAccount].
  Future<bool> clearFeePayerAccount() => setFeePayerAccount(null);
}