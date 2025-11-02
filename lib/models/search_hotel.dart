import 'hotel.dart';

class SearchHotel {
  final String code;
  final String name;
  final String? imageFullUrl;
  final String? imageLocation;
  final String? imageName;
  final String city;
  final String state;
  final String country;
  final int? star;
  final double? rating;
  final int? totalReviews;
  final String? priceDisplay;
  final num? price;
  final String? propertyUrl;

  SearchHotel({
    required this.code,
    required this.name,
    this.imageFullUrl,
    this.imageLocation,
    this.imageName,
    required this.city,
    required this.state,
    required this.country,
    this.star,
    this.rating,
    this.totalReviews,
    this.priceDisplay,
    this.price,
    this.propertyUrl,
  });

  factory SearchHotel.fromJson(Map<String, dynamic> json) {
    final addr = (json['propertyAddress'] as Map?) ?? const {};
    final img = (json['propertyImage'] as Map?) ?? const {};
    final gr = (json['googleReview'] as Map?)?['data'] as Map? ?? const {};
    final minPrice = (json['propertyMinPrice'] as Map?) ?? (json['markedPrice'] as Map?) ?? const {};

    return SearchHotel(
      propertyUrl: (json['propertyUrl'] ?? '').toString(),
      code: (json['propertyCode'] ?? '').toString(),
      name: (json['propertyName'] ?? '').toString(),
      imageFullUrl: img['fullUrl']?.toString(),
      imageLocation: img['location']?.toString(),
      imageName: img['imageName']?.toString(),
      city: (addr['city'] ?? '').toString(),
      state: (addr['state'] ?? '').toString(),
      country: (addr['country'] ?? '').toString(),
      star: _toInt(json['propertyStar']),
      rating: _toDouble(gr['overallRating']),
      totalReviews: _toInt(gr['totalUserRating']),
      priceDisplay: (minPrice['displayAmount'] ?? minPrice['currencyAmount'])?.toString(),
      price: _toNum(minPrice['amount']),
    );
  }

  String? get bestImageUrl {
    if (imageFullUrl != null && imageFullUrl!.isNotEmpty) return imageFullUrl;
    if (imageLocation != null && imageName != null) return '$imageLocation$imageName';
    return null;
  }
}

num? _toNum(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '');
int? _toInt(dynamic v) => _toNum(v)?.toInt();
double? _toDouble(dynamic v) => _toNum(v)?.toDouble();

extension SearchHotelToHotel on SearchHotel {
  Hotel toHotel() => Hotel(
    id: code,
    name: name,
    city: city,
    state: state,
    country: country,
    star: star,
    rating: rating,
    reviews: totalReviews,
    price: price,
    priceDisplay: priceDisplay,
    imageUrl: bestImageUrl,
    propertyUrl: propertyUrl
  );
}