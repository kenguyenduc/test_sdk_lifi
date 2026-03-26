import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/lifi_api_service.dart';
import 'bridge_event.dart';
import 'bridge_state.dart';

class BridgeBloc extends Bloc<BridgeEvent, BridgeState> {
  final LifiApiService _api;

  /// Demo wallet address for quote requests.
  static const _demoAddress =
      '0x552008c0f6870c2f77e5cC1d2eb9bdff03e30Ea0';

  BridgeBloc({LifiApiService? api})
      : _api = api ?? LifiApiService(),
        super(const BridgeState()) {
    on<BridgeLoadChains>(_onLoadChains);
    on<BridgeSelectFromChain>(_onSelectFromChain);
    on<BridgeSelectToChain>(_onSelectToChain);
    on<BridgeSelectFromToken>(_onSelectFromToken);
    on<BridgeSelectToToken>(_onSelectToToken);
    on<BridgeSetAmount>(_onSetAmount);
    on<BridgeSwapDirection>(_onSwapDirection);
    on<BridgeFetchQuote>(_onFetchQuote);
  }

  // ────────────────────────────────────────────
  // Event handlers
  // ────────────────────────────────────────────

  Future<void> _onLoadChains(
    BridgeLoadChains event,
    Emitter<BridgeState> emit,
  ) async {
    if (state.chains.isNotEmpty) return;

    emit(state.copyWith(chainsLoading: true, clearError: true));

    try {
      final chains = await _api.getChains();
      emit(state.copyWith(chains: chains, chainsLoading: false));

      // Default-select first two chains and load their tokens.
      if (chains.length >= 2) {
        emit(state.copyWith(fromChain: chains[0], toChain: chains[1]));
        await _loadTokensForChain(chains[0].id, isFrom: true, emit: emit);
        await _loadTokensForChain(chains[1].id, isFrom: false, emit: emit);
      }
    } catch (e) {
      emit(state.copyWith(
        chainsLoading: false,
        error: 'Failed to load chains: $e',
      ));
    }
  }

  Future<void> _onSelectFromChain(
    BridgeSelectFromChain event,
    Emitter<BridgeState> emit,
  ) async {
    emit(state.copyWith(
      fromChain: event.chain,
      clearFromToken: true,
      clearQuote: true,
      clearError: true,
    ));
    await _loadTokensForChain(event.chain.id, isFrom: true, emit: emit);
  }

  Future<void> _onSelectToChain(
    BridgeSelectToChain event,
    Emitter<BridgeState> emit,
  ) async {
    emit(state.copyWith(
      toChain: event.chain,
      clearToToken: true,
      clearQuote: true,
      clearError: true,
    ));
    await _loadTokensForChain(event.chain.id, isFrom: false, emit: emit);
  }

  void _onSelectFromToken(
    BridgeSelectFromToken event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(
      fromToken: event.token,
      clearQuote: true,
      clearError: true,
    ));
  }

  void _onSelectToToken(
    BridgeSelectToToken event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(
      toToken: event.token,
      clearQuote: true,
      clearError: true,
    ));
  }

  void _onSetAmount(
    BridgeSetAmount event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(amount: event.amount, clearQuote: true));
  }

  void _onSwapDirection(
    BridgeSwapDirection event,
    Emitter<BridgeState> emit,
  ) {
    emit(state.copyWith(
      fromChain: state.toChain,
      toChain: state.fromChain,
      fromToken: state.toToken,
      toToken: state.fromToken,
      fromTokens: state.toTokens,
      toTokens: state.fromTokens,
      clearQuote: true,
      clearError: true,
    ));
  }

  Future<void> _onFetchQuote(
    BridgeFetchQuote event,
    Emitter<BridgeState> emit,
  ) async {
    if (!state.canQuote) {
      emit(state.copyWith(
        error: 'Please select chains, tokens, and enter an amount.',
      ));
      return;
    }

    emit(state.copyWith(
      quoteLoading: true,
      clearQuote: true,
      clearError: true,
    ));

    try {
      final rawAmount =
          _toRawAmount(state.amount, state.fromToken!.decimals);

      final quote = await _api.getQuote(
        fromChainId: state.fromChain!.id,
        toChainId: state.toChain!.id,
        fromTokenAddress: state.fromToken!.address,
        toTokenAddress: state.toToken!.address,
        fromAmount: rawAmount,
        fromAddress: _demoAddress,
      );

      emit(state.copyWith(quote: quote, quoteLoading: false));
    } catch (e) {
      emit(state.copyWith(
        quoteLoading: false,
        error: e.toString(),
      ));
    }
  }

  // ────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────

  Future<void> _loadTokensForChain(
    int chainId, {
    required bool isFrom,
    required Emitter<BridgeState> emit,
  }) async {
    emit(state.copyWith(tokensLoading: true));

    try {
      final cache = Map<int, List<dynamic>>.from(state.tokensCache);
      if (!cache.containsKey(chainId)) {
        final tokenMap = await _api.getTokens([chainId]);
        cache[chainId] = tokenMap[chainId] ?? [];
      }

      final tokens = cache[chainId] ?? [];
      if (isFrom) {
        emit(state.copyWith(
          tokensCache: Map.unmodifiable(cache),
          fromTokens: List.unmodifiable(tokens),
          fromToken: tokens.isNotEmpty ? tokens.first : null,
          tokensLoading: false,
        ));
      } else {
        emit(state.copyWith(
          tokensCache: Map.unmodifiable(cache),
          toTokens: List.unmodifiable(tokens),
          toToken: tokens.isNotEmpty ? tokens.first : null,
          tokensLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        tokensLoading: false,
        error: 'Failed to load tokens: $e',
      ));
    }
  }

  String _toRawAmount(String humanAmount, int decimals) {
    final parts = humanAmount.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final paddedDecimal = decimalPart.padRight(decimals, '0');
    final truncated = paddedDecimal.substring(0, decimals);

    final raw = '$integerPart$truncated';
    return BigInt.parse(raw).toString();
  }

  /// Parse raw token amount to human-readable.
  static String formatTokenAmount(String rawAmount, int decimals) {
    if (rawAmount.isEmpty) return '0';

    final raw = BigInt.tryParse(rawAmount);
    if (raw == null) return '0';

    final divisor = BigInt.from(pow(10, decimals));
    final integerPart = raw ~/ divisor;
    final remainder = raw % divisor;

    final decimalStr = remainder.toString().padLeft(decimals, '0');
    final trimmed =
        decimalStr.length > 6 ? decimalStr.substring(0, 6) : decimalStr;
    final cleaned = trimmed.replaceAll(RegExp(r'0+$'), '');

    if (cleaned.isEmpty) return integerPart.toString();
    return '$integerPart.$cleaned';
  }
}
