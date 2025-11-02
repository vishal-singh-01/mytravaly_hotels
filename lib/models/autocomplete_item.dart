class AutoCompleteItem {
  final String group;
  final String display;
  final String type;
  final List<String> query;
  final String? city;
  final String? state;
  final String? country;

  const AutoCompleteItem({
    required this.group,
    required this.display,
    required this.type,
    required this.query,
    this.city,
    this.state,
    this.country,
  });
}
