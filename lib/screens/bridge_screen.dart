import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bridge_bloc.dart';
import '../bloc/bridge_event.dart';
import '../bloc/bridge_state.dart';
import '../models/lifi_models.dart';
import '../widgets/chain_token_selector.dart';

class BridgeScreen extends StatefulWidget {
  const BridgeScreen({super.key});

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  late AnimationController _swapAnimController;

  @override
  void initState() {
    super.initState();
    _swapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Load chains on init.
    context.read<BridgeBloc>().add(const BridgeLoadChains());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _swapAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF141428),
              Color(0xFF1A1A35),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<BridgeBloc, BridgeState>(
            builder: (context, state) {
              if (state.chainsLoading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF6C5CE7),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading chains...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFromCard(state),
                    _buildSwapButton(),
                    _buildToCard(state),
                    const SizedBox(height: 20),
                    _buildQuoteButton(state),
                    if (state.error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorCard(state.error!),
                    ],
                    if (state.quote != null) ...[
                      const SizedBox(height: 20),
                      _buildQuoteResult(state),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.swap_horiz_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bridge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Powered by LI.FI Protocol',
              style: TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFromCard(BridgeState state) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FROM',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (state.fromChain != null)
                _buildChainBadge(state.fromChain!),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildChainSelector(
                  label: 'Chain',
                  chain: state.fromChain,
                  chains: state.chains,
                  onSelect: (c) => context
                      .read<BridgeBloc>()
                      .add(BridgeSelectFromChain(c)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTokenSelector(
                  label: 'Token',
                  token: state.fromToken,
                  tokens: state.fromTokens,
                  isLoading: state.tokensLoading,
                  onSelect: (t) => context
                      .read<BridgeBloc>()
                      .add(BridgeSelectFromToken(t)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildAmountInput(state),
        ],
      ),
    );
  }

  Widget _buildToCard(BridgeState state) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TO',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (state.toChain != null) _buildChainBadge(state.toChain!),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildChainSelector(
                  label: 'Chain',
                  chain: state.toChain,
                  chains: state.chains,
                  onSelect: (c) => context
                      .read<BridgeBloc>()
                      .add(BridgeSelectToChain(c)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTokenSelector(
                  label: 'Token',
                  token: state.toToken,
                  tokens: state.toTokens,
                  isLoading: state.tokensLoading,
                  onSelect: (t) => context
                      .read<BridgeBloc>()
                      .add(BridgeSelectToToken(t)),
                ),
              ),
            ],
          ),
          if (state.quote != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Output',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${BridgeBloc.formatTokenAmount(state.quote!.estimate.toAmount, state.quote!.action.toToken.decimals)} ${state.quote!.action.toToken.symbol.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF00D2FF),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: GestureDetector(
          onTap: () {
            _swapAnimController.forward(from: 0);
            context.read<BridgeBloc>().add(const BridgeSwapDirection());
          },
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(
              CurvedAnimation(
                parent: _swapAnimController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BridgeState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
              onChanged: (v) =>
                  context.read<BridgeBloc>().add(BridgeSetAmount(v)),
            ),
          ),
          if (state.fromToken?.priceUSD != null &&
              _amountController.text.isNotEmpty) ...[
            Text(
              _estimateUSD(
                  _amountController.text, state.fromToken!.priceUSD!),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteButton(BridgeState state) {
    final canQuote = state.canQuote;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: canQuote
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
                )
              : null,
          color: canQuote ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canQuote
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canQuote && !state.quoteLoading
                ? () => context
                    .read<BridgeBloc>()
                    .add(const BridgeFetchQuote())
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: state.quoteLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      state.quote != null ? 'Refresh Quote' : 'Get Quote',
                      style: TextStyle(
                        color: canQuote
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteResult(BridgeState state) {
    final quote = state.quote!;
    final estimate = quote.estimate;

    return _buildGlassCard(
      borderColor: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  color: Color(0xFF00D2FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quote Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quote.toolName,
                  style: const TextStyle(
                    color: Color(0xFF00D2FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuoteRow(
            'You Send',
            '${BridgeBloc.formatTokenAmount(estimate.fromAmount, quote.action.fromToken.decimals)} ${quote.action.fromToken.symbol.toUpperCase()}',
          ),
          _buildQuoteRow(
            'You Receive (est.)',
            '${BridgeBloc.formatTokenAmount(estimate.toAmount, quote.action.toToken.decimals)} ${quote.action.toToken.symbol.toUpperCase()}',
            valueColor: const Color(0xFF00D2FF),
          ),
          _buildQuoteRow(
            'Min. Received',
            '${BridgeBloc.formatTokenAmount(estimate.toAmountMin, quote.action.toToken.decimals)} ${quote.action.toToken.symbol.toUpperCase()}',
          ),
          _buildQuoteRow(
            'Est. Duration',
            _formatDuration(estimate.executionDuration),
          ),
          if (estimate.feeCosts.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 24),
            Text(
              'FEES',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ...estimate.feeCosts.map(
              (fee) => _buildQuoteRow(
                fee.name,
                fee.amountUSD != null
                    ? '\$${double.tryParse(fee.amountUSD!)?.toStringAsFixed(4) ?? fee.amountUSD}'
                    : '${fee.amount} ${fee.token?.symbol ?? ''}',
              ),
            ),
          ],
          if (estimate.gasCosts.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 24),
            Text(
              'GAS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ...estimate.gasCosts.map(
              (gas) => _buildQuoteRow(
                gas.type,
                gas.amountUSD != null
                    ? '\$${double.tryParse(gas.amountUSD!)?.toStringAsFixed(4) ?? gas.amountUSD}'
                    : '${gas.amount} ${gas.token?.symbol ?? ''}',
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF6C5CE7)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Connect your wallet to bridge tokens'),
                        backgroundColor: const Color(0xFF6C5CE7),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const Center(
                    child: Text(
                      'Bridge Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ──

  Widget _buildGlassCard({
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildChainSelector({
    required String label,
    required LifiChain? chain,
    required List<LifiChain> chains,
    required Function(LifiChain) onSelect,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<LifiChain>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChainSelectorSheet(
            chains: chains,
            selected: chain,
          ),
        );
        if (result != null) onSelect(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            if (chain?.logoURI != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  chain!.logoURI!,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.language,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              )
            else
              const Icon(Icons.language,
                  color: Colors.white54, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                chain?.name ?? label,
                style: TextStyle(
                  color: chain != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenSelector({
    required String label,
    required LifiToken? token,
    required List<LifiToken> tokens,
    required bool isLoading,
    required Function(LifiToken) onSelect,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<LifiToken>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TokenSelectorSheet(
            tokens: tokens,
            selected: token,
            isLoading: isLoading,
          ),
        );
        if (result != null) onSelect(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            if (token?.logoURI != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  token!.logoURI!,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.toll_rounded,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              )
            else
              const Icon(Icons.toll_rounded,
                  color: Colors.white54, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                token?.symbol.toUpperCase() ?? label,
                style: TextStyle(
                  color: token != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChainBadge(LifiChain chain) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'ID: ${chain.id}',
        style: const TextStyle(
          color: Color(0xFF6C5CE7),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuoteRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilities ──

  String _estimateUSD(String amount, String priceUSD) {
    final a = double.tryParse(amount) ?? 0;
    final p = double.tryParse(priceUSD) ?? 0;
    final usd = a * p;
    if (usd >= 1000) return '≈ \$${usd.toStringAsFixed(0)}';
    if (usd >= 1) return '≈ \$${usd.toStringAsFixed(2)}';
    return '≈ \$${usd.toStringAsFixed(4)}';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins < 60) return '${mins}m ${secs}s';
    final hours = mins ~/ 60;
    return '${hours}h ${mins % 60}m';
  }
}
