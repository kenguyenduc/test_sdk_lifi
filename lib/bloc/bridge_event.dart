import 'package:equatable/equatable.dart';
import '../models/lifi_models.dart';

/// Base event for BridgeBloc.
sealed class BridgeEvent extends Equatable {
  const BridgeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all supported chains on init.
class BridgeLoadChains extends BridgeEvent {
  const BridgeLoadChains();
}

/// Select a "from" chain.
class BridgeSelectFromChain extends BridgeEvent {
  final LifiChain chain;
  const BridgeSelectFromChain(this.chain);

  @override
  List<Object?> get props => [chain.id];
}

/// Select a "to" chain.
class BridgeSelectToChain extends BridgeEvent {
  final LifiChain chain;
  const BridgeSelectToChain(this.chain);

  @override
  List<Object?> get props => [chain.id];
}

/// Select a "from" token.
class BridgeSelectFromToken extends BridgeEvent {
  final LifiToken token;
  const BridgeSelectFromToken(this.token);

  @override
  List<Object?> get props => [token.address, token.chainId];
}

/// Select a "to" token.
class BridgeSelectToToken extends BridgeEvent {
  final LifiToken token;
  const BridgeSelectToToken(this.token);

  @override
  List<Object?> get props => [token.address, token.chainId];
}

/// Update the amount to bridge.
class BridgeSetAmount extends BridgeEvent {
  final String amount;
  const BridgeSetAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Swap from ↔ to direction.
class BridgeSwapDirection extends BridgeEvent {
  const BridgeSwapDirection();
}

/// Fetch a quote from LI.FI API.
class BridgeFetchQuote extends BridgeEvent {
  const BridgeFetchQuote();
}
