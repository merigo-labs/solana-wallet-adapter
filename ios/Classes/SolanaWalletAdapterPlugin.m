#import "SolanaWalletAdapterPlugin.h"
#if __has_include(<solana_wallet_adapter/solana_wallet_adapter-Swift.h>)
#import <solana_wallet_adapter/solana_wallet_adapter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "solana_wallet_adapter-Swift.h"
#endif

@implementation SolanaWalletAdapterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSolanaWalletAdapterPlugin registerWithRegistrar:registrar];
}
@end
