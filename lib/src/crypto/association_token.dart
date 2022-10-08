/// Association Token
/// ------------------------------------------------------------------------------------------------

/// A base-64 URL encoding of an ECDSA public keypoint on the P-256 curve. 
/// 
/// The public keypoint is encoded using the `X9.62` public key format (0x04 || x || y), which is 
/// then base-64 URL encoded to create the association token.
typedef AssociationToken = String;