import 'package:dio/dio.dart';
import '../models/lifi_models.dart';

/// Service class for interacting with the LI.FI REST API using Dio.
/// Base URL: https://li.quest/v1
class LifiApiService {
  static const String _baseUrl = 'https://li.quest/v1';

  final Dio _dio;

  LifiApiService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              headers: {
                'Accept': 'application/json',
                if (apiKey != null) 'x-lifi-api-key': apiKey,
              },
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Fetch all supported chains.
  Future<List<LifiChain>> getChains() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/chains');
      final chainsList = response.data!['chains'] as List<dynamic>;
      return chainsList
          .map((e) => LifiChain.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch tokens for given chain IDs.
  Future<Map<int, List<LifiToken>>> getTokens(List<int> chainIds) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tokens',
        queryParameters: {'chains': chainIds.join(',')},
      );
      final tokensMap = response.data!['tokens'] as Map<String, dynamic>;

      final result = <int, List<LifiToken>>{};
      tokensMap.forEach((chainIdStr, tokensList) {
        final chainId = int.parse(chainIdStr);
        result[chainId] = (tokensList as List<dynamic>)
            .map((e) => LifiToken.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request a bridge/swap quote.
  Future<QuoteResponse> getQuote({
    required int fromChainId,
    required int toChainId,
    required String fromTokenAddress,
    required String toTokenAddress,
    required String fromAmount,
    required String fromAddress,
    double slippage = 0.03,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/quote',
        queryParameters: {
          'fromChain': fromChainId,
          'toChain': toChainId,
          'fromToken': fromTokenAddress,
          'toToken': toTokenAddress,
          'fromAmount': fromAmount,
          'fromAddress': fromAddress,
          'slippage': slippage,
        },
      );
      return QuoteResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check transaction status by txHash.
  Future<Map<String, dynamic>> getStatus({
    required String txHash,
    String? bridge,
    int? fromChain,
    int? toChain,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/status',
        queryParameters: {
          'txHash': txHash,
          if (bridge != null) 'bridge': bridge,
          if (fromChain != null) 'fromChain': fromChain,
          if (toChain != null) 'toChain': toChain,
        },
      );
      return response.data!;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  LifiApiException _handleError(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    String message;
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? e.message ?? 'Unknown error';
      } else {
        message = e.message ?? 'Unknown error';
      }
    } catch (_) {
      message = e.message ?? 'Unknown error';
    }
    return LifiApiException(statusCode, message);
  }
}

class LifiApiException implements Exception {
  final int statusCode;
  final String message;

  LifiApiException(this.statusCode, this.message);

  @override
  String toString() => 'LifiApiException($statusCode): $message';
}
