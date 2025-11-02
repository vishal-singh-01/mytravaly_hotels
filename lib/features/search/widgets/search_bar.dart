import 'package:flutter/material.dart';


typedef SuggestionLoader = Future<List<String>> Function(String q);


class SearchInput extends StatefulWidget {
  const SearchInput({super.key, required this.controller, required this.onChanged, required this.onSubmitted, required this.suggestionsFor});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final SuggestionLoader suggestionsFor;


  @override
  State<SearchInput> createState() => _SearchInputState();
}


class _SearchInputState extends State<SearchInput> {
  List<String> _suggestions = [];
  bool _loading = false;


  Future<void> _load() async {
    final q = widget.controller.text.trim();
    if (q.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _loading = true);
    try {
      _suggestions = await widget.suggestionsFor(q);
    } catch (e) {
      _suggestions = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Search by hotel, city, state, or country',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _loading
            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)))
            : IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ),
      onChanged: (v) {
        widget.onChanged(v);
        _load();
      },
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
    ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.take(8).map((s) => ActionChip(label: Text(s), onPressed: () => widget.onSubmitted(s))).toList(),
            ),
          ),
      ],
    );
  }
}