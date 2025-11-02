class Hotel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final num? price;
  final String? priceDisplay;
  final String? imageUrl;
  final double? rating;
  final int? reviews;
  final int? star;
  final String? propertyUrl;


  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    this.price,
    this.priceDisplay,
    this.imageUrl,
    this.rating,
    this.reviews,
    this.star,
    this.propertyUrl
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final addr = json['propertyAddress'] as Map<String, dynamic>?;

    String? displayAmount;
    num? amount;
    final staticPrice = json['staticPrice'] as Map<String, dynamic>?;
    final markedPrice = json['markedPrice'] as Map<String, dynamic>?;
    if (staticPrice != null) {
      amount = _toNum(staticPrice['amount']);
      displayAmount = (staticPrice['displayAmount'] ?? staticPrice['currencyAmount'])?.toString();
    } else if (markedPrice != null) {
      amount = _toNum(markedPrice['amount']);
      displayAmount = (markedPrice['displayAmount'] ?? markedPrice['currencyAmount'])?.toString();
    }

    final gr = json['googleReview'] as Map<String, dynamic>?;
    final grData = gr?['data'] as Map<String, dynamic>?;

    return Hotel(
      id: (json['id'] ?? json['property_id'] ?? json['propertyCode'] ?? '').toString(),
      name: (json['name'] ?? json['property_name'] ?? json['propertyName'] ?? 'Hotel').toString(),
      city: (json['city'] ?? addr?['city'] ?? '').toString(),
      state: (json['state'] ?? addr?['state'] ?? '').toString(),
      country: (json['country'] ?? addr?['country'] ?? '').toString(),
      price: amount,
      priceDisplay: displayAmount,
      imageUrl: (json['image'] ?? json['propertyImage'])?.toString(),
      rating: _toNum(grData?['overallRating'])?.toDouble(),
      reviews: _toNum(grData?['totalUserRating'])?.toInt(),
      star: _toNum(json['propertyStar'])?.toInt(),
      propertyUrl: json['propertyUrl']?.toString(),
    );
  }
}

num? _toNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}
