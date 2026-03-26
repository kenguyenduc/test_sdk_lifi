# LI.FI Bridge Integration Guide

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Setup](#3-setup)
4. [Project Structure](#4-project-structure)
5. [API Service — Dio](#5-api-service--dio)
6. [Data Models](#6-data-models)
7. [State Management — Flutter Bloc](#7-state-management--flutter-bloc)
8. [UI Components](#8-ui-components)
9. [Integration Guide](#9-integration-guide)
10. [Extending](#10-extending)

---

## 1. Overview

This module integrates the **LI.FI Protocol** to provide **cross-chain token bridging** in a Flutter Wallet application.

### Why REST API instead of SDK?

The official LI.FI SDK (`@lifi/sdk`) only supports JavaScript/TypeScript. For Flutter, we use the **LI.FI REST API** directly.

### API Information

| Property        | Value                              |
| --------------- | ---------------------------------- |
| **Base URL**    | `https://li.quest/v1`              |
| **Auth Header** | `x-lifi-api-key: YOUR_API_KEY`     |
| **Rate Limit**  | Unlimited (with API key)           |
| **Docs**        | https://docs.li.fi/api-reference/introduction |

### Tech Stack

| Component            | Package              |
| -------------------- | -------------------- |
| HTTP Client          | `dio ^5.4.0`         |
| State Management     | `flutter_bloc ^9.1.0`|
| Equality             | `equatable ^2.0.7`   |
| Number Formatting    | `intl ^0.19.0`       |

---

## 2. Architecture

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ BridgeScreen │  │ ChainSelector / Token... │  │
│  └──────┬───────┘  └──────────────────────────┘  │
│         │ BlocBuilder<BridgeBloc, BridgeState>    │
├─────────┼───────────────────────────────────────┤
│         ▼          Bloc Layer                    │
│  ┌──────────────┐                                │
│  │  BridgeBloc  │◄── BridgeEvent (sealed class)  │
│  │              │──► BridgeState (Equatable)      │
│  └──────┬───────┘                                │
├─────────┼───────────────────────────────────────┤
│         ▼        Service Layer                   │
│  ┌──────────────┐                                │
│  │LifiApiService│──► Dio HTTP Client             │
│  └──────┬───────┘                                │
│         ▼                                        │
│  ┌──────────────┐                                │
│  │ LI.FI REST   │  https://li.quest/v1           │
│  │    API       │                                │
│  └──────────────┘                                │
├─────────────────────────────────────────────────┤
│              Data Layer (Models)                 │
│  LifiChain · LifiToken · QuoteResponse           │
│  QuoteEstimate · FeeCost · GasCost               │
│  QuoteAction · TransactionRequest                │
└─────────────────────────────────────────────────┘
```

---

## 3. Setup

Add dependencies to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7
  intl: ^0.19.0
```

```bash
flutter pub get
```

---

## 4. Project Structure

```
lib/
├── main.dart                          # Entry point + BlocProvider
├── bloc/
│   ├── bridge_bloc.dart               # Business logic
│   ├── bridge_event.dart              # Events (sealed class)
│   └── bridge_state.dart              # Immutable state
├── models/
│   └── lifi_models.dart               # Data models parsed from API
├── screens/
│   └── bridge_screen.dart             # Bridge UI screen
├── services/
│   └── lifi_api_service.dart          # Dio-based REST client
└── widgets/
    └── chain_token_selector.dart      # Bottom sheet selectors
```

---

## 5. API Service — Dio

### Initialization

```dart
final api = LifiApiService(apiKey: 'YOUR_API_KEY');

// Or inject a custom Dio instance:
final dio = Dio(BaseOptions(
  baseUrl: 'https://li.quest/v1',
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
));
final api = LifiApiService(dio: dio);
```

### Endpoints

#### `getChains()` — Fetch supported blockchains

```dart
final chains = await api.getChains();
// Returns: List<LifiChain>
// API: GET /v1/chains
```

**Response example:**
```json
{
  "chains": [
    {
      "id": 1,
      "key": "eth",
      "name": "Ethereum",
      "coin": "ETH",
      "logoURI": "https://...",
      "nativeToken": { "address": "0x000...", "symbol": "ETH", "decimals": 18 }
    }
  ]
}
```

#### `getTokens(chainIds)` — Fetch tokens by chain

```dart
final tokensMap = await api.getTokens([1, 137]);
// Returns: Map<int, List<LifiToken>>
// API: GET /v1/tokens?chains=1,137
```

#### `getQuote(...)` — Request a bridge quote

```dart
final quote = await api.getQuote(
  fromChainId: 1,          // Ethereum
  toChainId: 42161,        // Arbitrum
  fromTokenAddress: '0x0000000000000000000000000000000000000000', // ETH
  toTokenAddress: '0x0000000000000000000000000000000000000000',   // ETH
  fromAmount: '1000000000000000000',  // 1 ETH (18 decimals)
  fromAddress: '0xYourWalletAddress',
  slippage: 0.03,          // 3%
);
// Returns: QuoteResponse
// API: GET /v1/quote?fromChain=...&toChain=...&...
```

**Response includes:**
- `action` — from/to token info, chain, slippage
- `estimate` — toAmount, toAmountMin, feeCosts, gasCosts, executionDuration
- `transactionRequest` — transaction data to send (from, to, data, value, gasLimit)

#### `getStatus(txHash)` — Check transaction status

```dart
final status = await api.getStatus(
  txHash: '0xabc123...',
  fromChain: 1,
  toChain: 42161,
);
// Returns: Map<String, dynamic>
// API: GET /v1/status?txHash=...
```

### Error Handling

All API errors are wrapped as `LifiApiException`:

```dart
try {
  final quote = await api.getQuote(...);
} on LifiApiException catch (e) {
  print('Status: ${e.statusCode}, Message: ${e.message}');
}
```

---

## 6. Data Models

| Model                | Description                                    |
| -------------------- | ---------------------------------------------- |
| `LifiChain`          | Blockchain (id, name, coin, logoURI, nativeToken) |
| `LifiToken`          | Token (chainId, address, symbol, decimals, priceUSD) |
| `QuoteResponse`      | Full quote result                              |
| `QuoteAction`        | From/to info within a quote                    |
| `QuoteEstimate`      | Estimated output, fees, gas, duration          |
| `FeeCost`            | Fee details (name, amount, amountUSD)          |
| `GasCost`            | Gas details (type, estimate, amountUSD)        |
| `TransactionRequest` | Transaction data (from, to, data, value)       |

All models include `factory fromJson(Map<String, dynamic> json)`:

```dart
final chain = LifiChain.fromJson(jsonData);
final token = LifiToken.fromJson(jsonData);
final quote = QuoteResponse.fromJson(jsonData);
```

---

## 7. State Management — Flutter Bloc

### Events

Type-safe events using `sealed class`:

```dart
sealed class BridgeEvent extends Equatable { ... }

BridgeLoadChains()              // Load chains on init
BridgeSelectFromChain(chain)    // Select source chain
BridgeSelectToChain(chain)      // Select destination chain
BridgeSelectFromToken(token)    // Select source token
BridgeSelectToToken(token)      // Select destination token
BridgeSetAmount(amount)         // Set bridge amount
BridgeSwapDirection()           // Swap from ↔ to
BridgeFetchQuote()              // Fetch bridge quote
```

### State

Immutable state with `copyWith` pattern:

```dart
class BridgeState extends Equatable {
  final List<LifiChain> chains;
  final bool chainsLoading;
  final LifiChain? fromChain;
  final LifiChain? toChain;
  final LifiToken? fromToken;
  final LifiToken? toToken;
  final String amount;
  final QuoteResponse? quote;
  final bool quoteLoading;
  final String? error;

  bool get canQuote => ...; // Computed property
}
```

**Note:** `copyWith` supports clearing nullable fields via flags:

```dart
state.copyWith(
  clearFromToken: true,  // Sets fromToken = null
  clearQuote: true,      // Sets quote = null
  clearError: true,      // Sets error = null
)
```

### Bloc — Processing Flow

```
App Start
  └─► BridgeLoadChains
        ├─► API: getChains()
        ├─► Auto-select chain[0] & chain[1]
        ├─► API: getTokens([chain0.id])
        ├─► API: getTokens([chain1.id])
        └─► Auto-select first token on each side

User selects chain/token
  └─► BridgeSelectFromChain / BridgeSelectToChain
        ├─► Clear token + quote
        ├─► API: getTokens([newChain.id])
        └─► Auto-select first token

User enters amount + taps "Get Quote"
  └─► BridgeFetchQuote
        ├─► Convert human amount → raw (BigInt)
        ├─► API: getQuote(...)
        └─► Emit state with QuoteResponse
```

---

## 8. UI Components

### BridgeScreen

Main screen with the following sections:

| Component           | Description                                      |
| ------------------- | ------------------------------------------------ |
| Header              | Icon + "Bridge" + "Powered by LI.FI Protocol"   |
| FROM Card           | Chain selector + Token selector + Amount input   |
| Swap Button         | Animated rotation button to swap from ↔ to       |
| TO Card             | Chain selector + Token selector + Estimated output |
| Quote Button        | "Get Quote" / "Refresh Quote" gradient button    |
| Quote Details       | Tool name, amounts, duration, fees, gas          |
| Bridge Now Button   | CTA button (requires wallet connection)          |

### ChainSelectorSheet / TokenSelectorSheet

Bottom sheets with:
- Search/filter functionality
- Logo display via `NetworkImage`
- Selected state indicator
- USD price display (for tokens)

### Widget Tree Usage

```dart
// main.dart
BlocProvider(
  create: (_) => BridgeBloc(),
  child: MaterialApp(home: BridgeScreen()),
);

// bridge_screen.dart
BlocBuilder<BridgeBloc, BridgeState>(
  builder: (context, state) {
    // Build UI from immutable state
  },
);

// Dispatch events
context.read<BridgeBloc>().add(BridgeFetchQuote());
```

---

## 9. Integration Guide

### Step 1: Copy files

Copy the following directories into your project:
- `lib/bloc/` — Bloc files
- `lib/models/` — Data models
- `lib/services/` — API service
- `lib/screens/` — Bridge screen
- `lib/widgets/` — Shared widgets

### Step 2: Add dependencies

```yaml
dependencies:
  dio: ^5.4.0
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7
```

### Step 3: Provide BlocProvider

```dart
// At a high level in the widget tree (or route-level)
BlocProvider(
  create: (_) => BridgeBloc(
    api: LifiApiService(apiKey: 'YOUR_LIFI_API_KEY'),
  ),
  child: BridgeScreen(),
);
```

### Step 4: Connect a real wallet

Replace `_demoAddress` in `BridgeBloc` with the actual wallet address:

```dart
// In BridgeBloc, replace:
static const _demoAddress = '0x552008c0f6...';

// With:
final String walletAddress; // Injected from wallet module
```

### Step 5: Execute transactions

After receiving a `QuoteResponse`, use `transactionRequest` to send the transaction:

```dart
final quote = state.quote!;
final txRequest = quote.transactionRequest!;

// Send via Web3 / WalletConnect:
final txHash = await wallet.sendTransaction(
  to: txRequest.to!,
  data: txRequest.data!,
  value: txRequest.value!,
  gasLimit: txRequest.gasLimit,
);

// Track status:
final status = await api.getStatus(txHash: txHash);
```

---

## 10. Extending

### Adding Dio Interceptors

```dart
final dio = Dio(BaseOptions(baseUrl: 'https://li.quest/v1'));

// Logging
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));

// Retry
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  retries: 3,
));

final api = LifiApiService(dio: dio);
```

### Routes API (Multiple Route Options)

LI.FI also supports a `/routes` endpoint for multiple route options:

```dart
// POST /v1/routes
Future<RoutesResponse> getRoutes({
  required int fromChainId,
  required int toChainId,
  required String fromTokenAddress,
  required String toTokenAddress,
  required String fromAmount,
}) async {
  final response = await _dio.post<Map<String, dynamic>>(
    '/routes',
    data: { /* ... */ },
  );
  return RoutesResponse.fromJson(response.data!);
}
```

### Token Approval

Some ERC-20 tokens require approval before bridging:

```dart
// Check approval address from quote
final approvalAddress = quote.estimate.approvalAddress;

// If present, approve the token first:
// 1. Call approve() on the ERC-20 contract
// 2. Wait for the approval tx to be confirmed
// 3. Send the bridge transaction
```

### Transaction Tracking

```dart
// Poll for status updates
Timer.periodic(Duration(seconds: 10), (timer) async {
  final status = await api.getStatus(txHash: txHash);
  if (status['status'] == 'DONE') {
    timer.cancel();
    // Bridge completed!
  } else if (status['status'] == 'FAILED') {
    timer.cancel();
    // Handle failure
  }
});
```
