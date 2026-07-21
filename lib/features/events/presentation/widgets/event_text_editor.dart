import 'dart:async';

import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/address_search_service.dart';
import '../../domain/address_suggestion.dart';

class EventTextEditorResult {
  const EventTextEditorResult({required this.text, this.address});

  final String text;
  final AddressSuggestion? address;
}

class EventTextEditor extends StatefulWidget {
  const EventTextEditor({
    required this.label,
    required this.initialValue,
    this.hintText,
    this.multiline = false,
    this.keyboardType,
    this.addressSearchService,
    this.cityHint,
    super.key,
  });

  final String label;
  final String initialValue;
  final String? hintText;
  final bool multiline;
  final TextInputType? keyboardType;
  final AddressSearchService? addressSearchService;
  final String? cityHint;

  static Future<EventTextEditorResult?> open(
    BuildContext context, {
    required String label,
    required String initialValue,
    String? hintText,
    bool multiline = false,
    TextInputType? keyboardType,
    AddressSearchService? addressSearchService,
    String? cityHint,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<EventTextEditorResult>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, _, _) => EventTextEditor(
          label: label,
          initialValue: initialValue,
          hintText: hintText,
          multiline: multiline,
          keyboardType: keyboardType,
          addressSearchService: addressSearchService,
          cityHint: cityHint,
        ),
        transitionsBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<EventTextEditor> createState() => _EventTextEditorState();
}

class _EventTextEditorState extends State<EventTextEditor> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<AddressSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _searched = false;
  bool _searchFailed = false;

  bool get _isAddress => widget.addressSearchService != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          key: const Key('event-text-editor'),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              key: const Key('event-editor-cancel'),
              tooltip: context.tr('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Text(widget.label),
            actions: [
              TextButton(
                key: const Key('event-editor-done'),
                onPressed: _complete,
                child: Text(context.tr('Done')),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('event-editor-input'),
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType:
                      widget.keyboardType ??
                      (widget.multiline
                          ? TextInputType.multiline
                          : TextInputType.text),
                  textInputAction: widget.multiline
                      ? TextInputAction.newline
                      : TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: widget.multiline ? 4 : 1,
                  maxLines: widget.multiline ? 6 : 1,
                  onChanged: _isAddress ? _scheduleAddressSearch : null,
                  onSubmitted: widget.multiline ? null : (_) => _complete(),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hintText,
                    prefixIcon: Icon(
                      _isAddress
                          ? Icons.location_on_outlined
                          : widget.multiline
                          ? Icons.notes_rounded
                          : Icons.edit_outlined,
                    ),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: context.tr('Clear'),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _suggestions = const [];
                                _searched = false;
                              });
                            },
                            icon: const Icon(Icons.backspace_outlined),
                          ),
                  ),
                ),
                if (_searching) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (_isAddress) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.travel_explore_rounded,
                        size: 18,
                        color: AppColors.primaryBright,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('Address suggestions'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        'IGN',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildAddressResults(context)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressResults(BuildContext context) {
    if (!_searched && _suggestions.isEmpty) {
      return _EditorStatus(
        icon: Icons.location_searching_rounded,
        message: context.tr(
          'Start typing a street address to see verified suggestions.',
        ),
      );
    }
    if (_searchFailed) {
      return _EditorStatus(
        icon: Icons.wifi_off_rounded,
        message: context.tr(
          'Address suggestions are unavailable. You can still enter the address manually.',
        ),
      );
    }
    if (_searched && !_searching && _suggestions.isEmpty) {
      return _EditorStatus(
        icon: Icons.location_off_outlined,
        message: context.tr('No matching address found.'),
      );
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          key: Key('address-suggestion-$index'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          leading: const Icon(Icons.place_outlined),
          title: Text(
            suggestion.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: suggestion.city.isEmpty
              ? null
              : Text(
                  [
                    suggestion.postalCode,
                    suggestion.city,
                  ].where((value) => value.isNotEmpty).join(' '),
                ),
          trailing: const Icon(Icons.north_west_rounded, size: 18),
          onTap: () => Navigator.of(context).pop(
            EventTextEditorResult(text: suggestion.label, address: suggestion),
          ),
        );
      },
    );
  }

  void _scheduleAddressSearch(String value) {
    setState(() {});
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _suggestions = const [];
        _searched = false;
        _searchFailed = false;
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 380), () {
      _searchAddress(value);
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() {
      _searching = true;
      _searchFailed = false;
    });
    try {
      final results = await widget.addressSearchService!.search(
        query,
        cityHint: widget.cityHint,
      );
      if (!mounted || query != _controller.text) return;
      setState(() {
        _suggestions = results;
        _searched = true;
      });
    } on AddressSearchException {
      if (!mounted || query != _controller.text) return;
      setState(() {
        _suggestions = const [];
        _searched = true;
        _searchFailed = true;
      });
    } finally {
      if (mounted && query == _controller.text) {
        setState(() => _searching = false);
      }
    }
  }

  void _complete() {
    Navigator.of(
      context,
    ).pop(EventTextEditorResult(text: _controller.text.trim()));
  }
}

class _EditorStatus extends StatelessWidget {
  const _EditorStatus({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
