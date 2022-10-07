/// Types
/// ------------------------------------------------------------------------------------------------

/// An opaque string representing a unique identifying token issued by the wallet endpoint to the 
/// dApp endpoint. The format and contents are an implementation detail of the wallet endpoint. The 
/// dApp endpoint can use this on future connections to reauthorize access to privileged methods.
typedef AuthToken = String;

/// A base-64 encoded `account address`.
typedef Base64EncodedAddress = String;

/// A base-64 encoded `transaction signature`.
typedef Base64EncodedSignature = String;

/// A base-64 encoded `message payload`.
typedef Base64EncodedMessage = String;

/// A base-64 encoded `signed message`.
typedef Base64EncodedSignedMessage = String;

/// A base-64 encoded `signed transaction`.
typedef Base64EncodedSignedTransaction = String;

/// A base-64 encoded `transaction payload`.
typedef Base64EncodedTransaction = String;