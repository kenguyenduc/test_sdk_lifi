import 'package:flutter/material.dart';
import '../models/lifi_models.dart';

/// Bottom sheet for selecting a chain.
class ChainSelectorSheet extends StatefulWidget {
  final List<LifiChain> chains;
  final LifiChain? selected;

  const ChainSelectorSheet({
    super.key,
    required this.chains,
    this.selected,
  });

  @override
  State<ChainSelectorSheet> createState() => _ChainSelectorSheetState();
}

class _ChainSelectorSheetState extends State<ChainSelectorSheet> {
  String _search = '';

  List<LifiChain> get _filtered => _search.isEmpty
      ? widget.chains
      : widget.chains
          .where((c) =>
              c.name.toLowerCase().contains(_search.toLowerCase()) ||
              c.coin.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1B2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Chain',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search chains...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final chain = _filtered[i];
                final isSelected = widget.selected?.id == chain.id;
                return ListTile(
                  leading: _buildLogo(chain.logoURI, chain.name),
                  title: Text(
                    chain.name,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF6C5CE7)
                          : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    'Chain ID: ${chain.id}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF6C5CE7))
                      : null,
                  onTap: () => Navigator.pop(context, chain),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for selecting a token.
class TokenSelectorSheet extends StatefulWidget {
  final List<LifiToken> tokens;
  final LifiToken? selected;
  final bool isLoading;

  const TokenSelectorSheet({
    super.key,
    required this.tokens,
    this.selected,
    this.isLoading = false,
  });

  @override
  State<TokenSelectorSheet> createState() => _TokenSelectorSheetState();
}

class _TokenSelectorSheetState extends State<TokenSelectorSheet> {
  String _search = '';

  List<LifiToken> get _filtered => _search.isEmpty
      ? widget.tokens
      : widget.tokens
          .where((t) =>
              t.symbol.toLowerCase().contains(_search.toLowerCase()) ||
              t.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1B2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Token',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tokens...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final token = _filtered[i];
                  final isSelected =
                      widget.selected?.address == token.address &&
                          widget.selected?.chainId == token.chainId;
                  return ListTile(
                    leading: _buildLogo(token.logoURI, token.symbol),
                    title: Text(
                      token.symbol.toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      token.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (token.priceUSD != null)
                          Text(
                            '\$${_formatPrice(token.priceUSD!)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF6C5CE7), size: 18),
                      ],
                    ),
                    onTap: () => Navigator.pop(context, token),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildLogo(String? logoURI, String fallbackText) {
  if (logoURI != null && logoURI.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        logoURI,
        width: 36,
        height: 36,
        errorBuilder: (_, __, ___) => _fallbackAvatar(fallbackText),
      ),
    );
  }
  return _fallbackAvatar(fallbackText);
}

Widget _fallbackAvatar(String text) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
    ),
    alignment: Alignment.center,
    child: Text(
      text.isNotEmpty ? text[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String _formatPrice(String priceStr) {
  final price = double.tryParse(priceStr) ?? 0;
  if (price >= 1000) return price.toStringAsFixed(0);
  if (price >= 1) return price.toStringAsFixed(2);
  if (price >= 0.01) return price.toStringAsFixed(4);
  return price.toStringAsFixed(6);
}
