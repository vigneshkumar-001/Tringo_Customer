class ServicesListResponse {
  final bool status;
  final ServiceData? data;

  ServicesListResponse({
    required this.status,
    this.data,
  });

  factory ServicesListResponse.fromJson(Map<String, dynamic> json) {
    return ServicesListResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? ServiceData.fromJson(json['data']) : null,
    );
  }
}

class ServiceData {
  final int total;
  final List<CategoryModel> categories;
  final List<ServiceItem> items;

  ServiceData({
    required this.total,
    required this.categories,
    required this.items,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      total: json['total'] ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryModel {
  final String? slug; // can be null as per JSON
  final String label;
  final int count;

  CategoryModel({
    required this.slug,
    required this.label,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      slug: json['slug'], // null or String
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ServiceItem {
  final String id;
  final String englishName;
  final String tamilName;
  final num startsAt;
  final num offerPrice;
  final int durationMinutes;
  final String offerLabel;
  final String offerValue;
  final String description;
  final String status;
  final String? primaryImageUrl;
  final String category;
  final String subCategory;

  // 🔹 NEW FIELDS
  final int? rating;
  final int? ratingCount;
  final double? distanceKm;
  final String? distanceLabel;

  ServiceItem({
    required this.id,
    required this.englishName,
    required this.tamilName,
    required this.startsAt,
    required this.offerPrice,
    required this.durationMinutes,
    required this.offerLabel,
    required this.offerValue,
    required this.description,
    required this.status,
    required this.primaryImageUrl,
    required this.category,
    required this.subCategory,
      this.rating,
      this.ratingCount,
    this.distanceKm,
    this.distanceLabel,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? '',
      englishName: json['englishName'] ?? '',
      tamilName: json['tamilName'] ?? '',
      startsAt: json['startsAt'] ?? 0,
      offerPrice: json['offerPrice'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      offerLabel: json['offerLabel'] ?? '',
      offerValue: json['offerValue'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      primaryImageUrl: json['primaryImageUrl'],
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',

      // 🔹 NEW
      rating: json['rating'] ?? 0,
      ratingCount: json['ratingCount'] ?? 0,
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : null,
      distanceLabel: json['distanceLabel'],
    );
  }
}

class ServiceDataFeature {
  final String id;
  final String label;
  final String value;
  final String? language;

  ServiceDataFeature({
    required this.id,
    required this.label,
    required this.value,
    this.language,
  });

  factory ServiceDataFeature.fromJson(Map<String, dynamic> json) {
    return ServiceDataFeature(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      language: json['language'],
    );
  }
}


// class   ServicesListResponse {
//   final bool status;
//   final ServiceData data;
//
//   ServicesListResponse({
//     required this.status,
//     required this.data,
//   });
//
//   factory ServicesListResponse.fromJson(Map<String, dynamic> json) {
//     return ServicesListResponse(
//       status: json['status'] ?? false,
//       data: ServiceData.fromJson(json['data']),
//     );
//   }
// }
//
// class ServiceData {
//   final int total;
//   final List<CategoryModel> categories;
//   final List<ServiceItem> items;
//
//   ServiceData({
//     required this.total,
//     required this.categories,
//     required this.items,
//   });
//
//   factory ServiceData.fromJson(Map<String, dynamic> json) {
//     return ServiceData(
//       total: json['total'] ?? 0,
//       categories: (json['categories'] as List)
//           .map((e) => CategoryModel.fromJson(e))
//           .toList(),
//       items: (json['items'] as List)
//           .map((e) => ServiceItem.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
//
// class CategoryModel {
//   final String? slug;
//   final String label;
//   final int count;
//
//   CategoryModel({
//     required this.slug,
//     required this.label,
//     required this.count,
//   });
//
//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       slug: json['slug'],
//       label: json['label'] ?? '',
//       count: json['count'] ?? 0,
//     );
//   }
// }
//
//
// class ServiceItem {
//   final String id;
//   final String englishName;
//   final String tamilName;
//   final num startsAt;
//   final num offerPrice;
//   final int durationMinutes;
//   final String offerLabel;
//   final String offerValue;
//   final String description;
//   final String status;
//   final String? primaryImageUrl;
//   final String category;
//   final String subCategory;
//
//   ServiceItem({
//     required this.id,
//     required this.englishName,
//     required this.tamilName,
//     required this.startsAt,
//     required this.offerPrice,
//     required this.durationMinutes,
//     required this.offerLabel,
//     required this.offerValue,
//     required this.description,
//     required this.status,
//     required this.primaryImageUrl,
//     required this.category,
//     required this.subCategory,
//   });
//
//   factory ServiceItem.fromJson(Map<String, dynamic> json) {
//     return ServiceItem(
//       id: json['id'],
//       englishName: json['englishName'] ?? '',
//       tamilName: json['tamilName'] ?? '',
//       startsAt: json['startsAt'],
//       offerPrice: json['offerPrice'],
//       durationMinutes: json['durationMinutes'] ?? 0,
//       offerLabel: json['offerLabel'] ?? '',
//       offerValue: json['offerValue'] ?? '',
//       description: json['description'] ?? '',
//       status: json['status'] ?? '',
//       primaryImageUrl: json['primaryImageUrl'],
//       category: json['category'] ?? '',
//       subCategory: json['subCategory'] ?? '',
//     );
//   }
// }
//
//
// class ServiceDataFeature {
//   final String id;
//   final String label;
//   final String value;
//   final String? language;
//
//   ServiceDataFeature({
//     required this.id,
//     required this.label,
//     required this.value,
//     this.language,
//   });
//
//   factory ServiceDataFeature.fromJson(Map<String, dynamic> json) {
//     return ServiceDataFeature(
//       id: json['id'] ?? '',
//       label: json['label'] ?? '',
//       value: json['value'] ?? '',
//       language: json['language'],
//     );
//   }
// }
