// Data models for LI.FI API responses.

class LifiChain {
  final int id;
  final String key;
  final String name;
  final String coin;
  final String? logoURI;
  final LifiToken? nativeToken;

  LifiChain({
    required this.id,
    required this.key,
    required this.name,
    required this.coin,
    this.logoURI,
    this.nativeToken,
  });

  factory LifiChain.fromJson(Map<String, dynamic> json) {
    return LifiChain(
      id: json['id'] as int,
      key: json['key'] as String,
      name: json['name'] as String,
      coin: json['coin'] as String,
      logoURI: json['logoURI'] as String?,
      nativeToken: json['nativeToken'] != null
          ? LifiToken.fromJson(json['nativeToken'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LifiToken {
  final int chainId;
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final String? priceUSD;
  final String? coinKey;
  final String? logoURI;

  LifiToken({
    required this.chainId,
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    this.priceUSD,
    this.coinKey,
    this.logoURI,
  });

  factory LifiToken.fromJson(Map<String, dynamic> json) {
    return LifiToken(
      chainId: json['chainId'] as int,
      address: json['address'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: json['decimals'] as int,
      priceUSD: json['priceUSD'] as String?,
      coinKey: json['coinKey'] as String?,
      logoURI: json['logoURI'] as String?,
    );
  }
}

class QuoteEstimate {
  final String tool;
  final String? approvalAddress;
  final String toAmount;
  final String toAmountMin;
  final String fromAmount;
  final int executionDuration;
  final List<FeeCost> feeCosts;
  final List<GasCost> gasCosts;

  QuoteEstimate({
    required this.tool,
    this.approvalAddress,
    required this.toAmount,
    required this.toAmountMin,
    required this.fromAmount,
    required this.executionDuration,
    required this.feeCosts,
    required this.gasCosts,
  });

  factory QuoteEstimate.fromJson(Map<String, dynamic> json) {
    return QuoteEstimate(
      tool: json['tool'] as String,
      approvalAddress: json['approvalAddress'] as String?,
      toAmount: json['toAmount'] as String,
      toAmountMin: json['toAmountMin'] as String,
      fromAmount: json['fromAmount'] as String,
      executionDuration: json['executionDuration'] as int? ?? 0,
      feeCosts: (json['feeCosts'] as List<dynamic>?)
              ?.map((e) => FeeCost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gasCosts: (json['gasCosts'] as List<dynamic>?)
              ?.map((e) => GasCost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FeeCost {
  final String name;
  final String? description;
  final String amount;
  final String? amountUSD;
  final String? percentage;
  final LifiToken? token;

  FeeCost({
    required this.name,
    this.description,
    required this.amount,
    this.amountUSD,
    this.percentage,
    this.token,
  });

  factory FeeCost.fromJson(Map<String, dynamic> json) {
    return FeeCost(
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: json['amount'] as String,
      amountUSD: json['amountUSD'] as String?,
      percentage: json['percentage'] as String?,
      token: json['token'] != null
          ? LifiToken.fromJson(json['token'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GasCost {
  final String type;
  final String estimate;
  final String? limit;
  final String amount;
  final String? amountUSD;
  final LifiToken? token;

  GasCost({
    required this.type,
    required this.estimate,
    this.limit,
    required this.amount,
    this.amountUSD,
    this.token,
  });

  factory GasCost.fromJson(Map<String, dynamic> json) {
    return GasCost(
      type: json['type'] as String,
      estimate: json['estimate'] as String,
      limit: json['limit'] as String?,
      amount: json['amount'] as String,
      amountUSD: json['amountUSD'] as String?,
      token: json['token'] != null
          ? LifiToken.fromJson(json['token'] as Map<String, dynamic>)
          : null,
    );
  }
}

class QuoteAction {
  final LifiToken fromToken;
  final LifiToken toToken;
  final String fromAmount;
  final int fromChainId;
  final int toChainId;
  final double slippage;

  QuoteAction({
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.fromChainId,
    required this.toChainId,
    required this.slippage,
  });

  factory QuoteAction.fromJson(Map<String, dynamic> json) {
    return QuoteAction(
      fromToken:
          LifiToken.fromJson(json['fromToken'] as Map<String, dynamic>),
      toToken: LifiToken.fromJson(json['toToken'] as Map<String, dynamic>),
      fromAmount: json['fromAmount'] as String,
      fromChainId: json['fromChainId'] as int,
      toChainId: json['toChainId'] as int,
      slippage: (json['slippage'] as num).toDouble(),
    );
  }
}

class TransactionRequest {
  final String? from;
  final String? to;
  final String? data;
  final String? value;
  final String? gasLimit;
  final String? gasPrice;
  final int? chainId;

  TransactionRequest({
    this.from,
    this.to,
    this.data,
    this.value,
    this.gasLimit,
    this.gasPrice,
    this.chainId,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
      from: json['from'] as String?,
      to: json['to'] as String?,
      data: json['data'] as String?,
      value: json['value'] as String?,
      gasLimit: json['gasLimit'] as String?,
      gasPrice: json['gasPrice'] as String?,
      chainId: json['chainId'] as int?,
    );
  }
}

class QuoteResponse {
  final String id;
  final String type;
  final String tool;
  final Map<String, dynamic>? toolDetails;
  final QuoteAction action;
  final QuoteEstimate estimate;
  final TransactionRequest? transactionRequest;

  QuoteResponse({
    required this.id,
    required this.type,
    required this.tool,
    this.toolDetails,
    required this.action,
    required this.estimate,
    this.transactionRequest,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    return QuoteResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      tool: json['tool'] as String,
      toolDetails: json['toolDetails'] as Map<String, dynamic>?,
      action:
          QuoteAction.fromJson(json['action'] as Map<String, dynamic>),
      estimate:
          QuoteEstimate.fromJson(json['estimate'] as Map<String, dynamic>),
      transactionRequest: json['transactionRequest'] != null
          ? TransactionRequest.fromJson(
              json['transactionRequest'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Tool display name from toolDetails
  String get toolName =>
      (toolDetails?['name'] as String?) ?? tool;

  /// Tool logo from toolDetails
  String? get toolLogoURI =>
      toolDetails?['logoURI'] as String?;
}
