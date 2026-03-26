import 'package:equatable/equatable.dart';
import '../models/lifi_models.dart';

/// State for BridgeBloc.
class BridgeState extends Equatable {
  final List<LifiChain> chains;
  final bool chainsLoading;

  final Map<int, List<LifiToken>> tokensCache;
  final List<LifiToken> fromTokens;
  final List<LifiToken> toTokens;
  final bool tokensLoading;

  final LifiChain? fromChain;
  final LifiChain? toChain;
  final LifiToken? fromToken;
  final LifiToken? toToken;

  final String amount;
  final QuoteResponse? quote;
  final bool quoteLoading;

  final String? error;

  const BridgeState({
    this.chains = const [],
    this.chainsLoading = false,
    this.tokensCache = const {},
    this.fromTokens = const [],
    this.toTokens = const [],
    this.tokensLoading = false,
    this.fromChain,
    this.toChain,
    this.fromToken,
    this.toToken,
    this.amount = '',
    this.quote,
    this.quoteLoading = false,
    this.error,
  });

  /// Whether the user can request a quote.
  bool get canQuote =>
      fromChain != null &&
      toChain != null &&
      fromToken != null &&
      toToken != null &&
      amount.isNotEmpty;

  BridgeState copyWith({
    List<LifiChain>? chains,
    bool? chainsLoading,
    Map<int, List<LifiToken>>? tokensCache,
    List<LifiToken>? fromTokens,
    List<LifiToken>? toTokens,
    bool? tokensLoading,
    LifiChain? fromChain,
    LifiChain? toChain,
    LifiToken? fromToken,
    LifiToken? toToken,
    String? amount,
    QuoteResponse? quote,
    bool? quoteLoading,
    String? error,
    // Flags to allow setting nullable fields to null.
    bool clearFromToken = false,
    bool clearToToken = false,
    bool clearQuote = false,
    bool clearError = false,
  }) {
    return BridgeState(
      chains: chains ?? this.chains,
      chainsLoading: chainsLoading ?? this.chainsLoading,
      tokensCache: tokensCache ?? this.tokensCache,
      fromTokens: fromTokens ?? this.fromTokens,
      toTokens: toTokens ?? this.toTokens,
      tokensLoading: tokensLoading ?? this.tokensLoading,
      fromChain: fromChain ?? this.fromChain,
      toChain: toChain ?? this.toChain,
      fromToken: clearFromToken ? null : (fromToken ?? this.fromToken),
      toToken: clearToToken ? null : (toToken ?? this.toToken),
      amount: amount ?? this.amount,
      quote: clearQuote ? null : (quote ?? this.quote),
      quoteLoading: quoteLoading ?? this.quoteLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        chains.length,
        chainsLoading,
        tokensCache.length,
        fromTokens.length,
        toTokens.length,
        tokensLoading,
        fromChain?.id,
        toChain?.id,
        fromToken?.address,
        toToken?.address,
        amount,
        quote?.id,
        quoteLoading,
        error,
      ];
}
