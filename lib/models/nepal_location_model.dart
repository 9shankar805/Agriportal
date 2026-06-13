
class NepalLocationResponse {
  final List<Province> provinceList;

  NepalLocationResponse({required this.provinceList});

  factory NepalLocationResponse.fromJson(Map<String, dynamic> json) {
    return NepalLocationResponse(
      provinceList: (json['provinceList'] as List<dynamic>)
          .map((e) => Province.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinceList': provinceList.map((e) => e.toJson()).toList(),
    };
  }
}

class Province {
  final int id;
  final String nameEn;
  final String? nameNp;
  final List<District> districtList;

  Province({
    required this.id,
    required this.nameEn,
    this.nameNp,
    required this.districtList,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as int,
      nameEn: json['name'] as String,
      nameNp: json['nameNp'] as String?,
      districtList: (json['districtList'] as List<dynamic>)
          .map((e) => District.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nameEn,
      'nameNp': nameNp,
      'districtList': districtList.map((e) => e.toJson()).toList(),
    };
  }
}

class District {
  final int id;
  final String nameEn;
  final String? nameNp;
  final List<Municipality> municipalityList;

  District({
    required this.id,
    required this.nameEn,
    this.nameNp,
    required this.municipalityList,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      nameEn: json['name'] as String,
      nameNp: json['nameNp'] as String?,
      municipalityList: (json['municipalityList'] as List<dynamic>)
          .map((e) => Municipality.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nameEn,
      'nameNp': nameNp,
      'municipalityList': municipalityList.map((e) => e.toJson()).toList(),
    };
  }
}

class Municipality {
  final int id;
  final String nameEn;
  final String? nameNp;

  Municipality({
    required this.id,
    required this.nameEn,
    this.nameNp,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id'] as int,
      nameEn: json['name'] as String,
      nameNp: json['nameNp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nameEn,
      'nameNp': nameNp,
    };
  }
}
