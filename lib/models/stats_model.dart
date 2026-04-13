class StatsOverview {
  final int days;
  final DateTime? sinceDate;
  final StatsUsers users;
  final StatsLivres livres;
  final StatsSales sales;
  final DateTime? lastUpdatedAt;

  const StatsOverview({
    required this.days,
    required this.sinceDate,
    required this.users,
    required this.livres,
    required this.sales,
    required this.lastUpdatedAt,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    final window = _asMap(json['window']);
    final data = _asMap(json['data']);

    return StatsOverview(
      days: _toInt(window['days']),
      sinceDate: _toDateTime(window['sinceDate']),
      users: StatsUsers.fromJson(_asMap(data['users'])),
      livres: StatsLivres.fromJson(_asMap(data['livres'])),
      sales: StatsSales.fromJson(_asMap(data['sales'])),
      lastUpdatedAt: _toDateTime(json['lastUpdatedAt']),
    );
  }
}

class StatsUsers {
  final int total;
  final int active;
  final int inactive;
  final int newInWindow;

  const StatsUsers({
    required this.total,
    required this.active,
    required this.inactive,
    required this.newInWindow,
  });

  factory StatsUsers.fromJson(Map<String, dynamic> json) {
    return StatsUsers(
      total: _toInt(json['total']),
      active: _toInt(json['active']),
      inactive: _toInt(json['inactive']),
      newInWindow: _toInt(json['newInWindow']),
    );
  }
}

class StatsLivres {
  final int total;
  final int active;
  final int inactive;
  final int newInWindow;

  const StatsLivres({
    required this.total,
    required this.active,
    required this.inactive,
    required this.newInWindow,
  });

  factory StatsLivres.fromJson(Map<String, dynamic> json) {
    return StatsLivres(
      total: _toInt(json['total']),
      active: _toInt(json['active']),
      inactive: _toInt(json['inactive']),
      newInWindow: _toInt(json['newInWindow']),
    );
  }
}

class StatsSales {
  final StatsSalesMetrics allTime;
  final StatsSalesMetrics inWindow;
  final double avgOrderValue;

  const StatsSales({
    required this.allTime,
    required this.inWindow,
    required this.avgOrderValue,
  });

  factory StatsSales.fromJson(Map<String, dynamic> json) {
    return StatsSales(
      allTime: StatsSalesMetrics.fromJson(_asMap(json['allTime'])),
      inWindow: StatsSalesMetrics.fromJson(_asMap(json['inWindow'])),
      avgOrderValue: _toDouble(json['avgOrderValue']),
    );
  }
}

class StatsSalesMetrics {
  final int orders;
  final double revenue;
  final int booksSold;

  const StatsSalesMetrics({
    required this.orders,
    required this.revenue,
    required this.booksSold,
  });

  factory StatsSalesMetrics.fromJson(Map<String, dynamic> json) {
    return StatsSalesMetrics(
      orders: _toInt(json['orders']),
      revenue: _toDouble(json['revenue']),
      booksSold: _toInt(json['booksSold']),
    );
  }
}

class TopLivreStat {
  final String livreId;
  final String titre;
  final List<String> auteur;
  final String? categorie;
  final bool actif;
  final double noteMoyenne;
  final int copiesSold;
  final double revenue;
  final int ordersCount;

  const TopLivreStat({
    required this.livreId,
    required this.titre,
    required this.auteur,
    required this.categorie,
    required this.actif,
    required this.noteMoyenne,
    required this.copiesSold,
    required this.revenue,
    required this.ordersCount,
  });

  factory TopLivreStat.fromJson(Map<String, dynamic> json) {
    return TopLivreStat(
      livreId: _toString(json['livreId']),
      titre: _toString(json['titre']),
      auteur: _toStringList(json['auteur']),
      categorie: _nullableToString(json['categorie']),
      actif: _toBool(json['actif']),
      noteMoyenne: _toDouble(json['noteMoyenne']),
      copiesSold: _toInt(json['copiesSold']),
      revenue: _toDouble(json['revenue']),
      ordersCount: _toInt(json['ordersCount']),
    );
  }
}

class SalesTrendStats {
  final String groupBy;
  final int days;
  final DateTime? sinceDate;
  final List<SalesTrendPoint> points;

  const SalesTrendStats({
    required this.groupBy,
    required this.days,
    required this.sinceDate,
    required this.points,
  });

  factory SalesTrendStats.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return SalesTrendStats(
      groupBy: _toString(data['groupBy'], fallback: 'day'),
      days: _toInt(data['days']),
      sinceDate: _toDateTime(data['sinceDate']),
      points: _toList(
        data['points'],
      ).map((e) => SalesTrendPoint.fromJson(_asMap(e))).toList(),
    );
  }
}

class SalesTrendPoint {
  final String period;
  final int orders;
  final double revenue;
  final int booksSold;

  const SalesTrendPoint({
    required this.period,
    required this.orders,
    required this.revenue,
    required this.booksSold,
  });

  factory SalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendPoint(
      period: _toString(json['period']),
      orders: _toInt(json['orders']),
      revenue: _toDouble(json['revenue']),
      booksSold: _toInt(json['booksSold']),
    );
  }
}

class UsersStats {
  final UsersSummary summary;
  final RegistrationsTrend registrationsTrend;
  final List<TopBuyer> topBuyers;

  const UsersStats({
    required this.summary,
    required this.registrationsTrend,
    required this.topBuyers,
  });

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return UsersStats(
      summary: UsersSummary.fromJson(_asMap(data['summary'])),
      registrationsTrend: RegistrationsTrend.fromJson(
        _asMap(data['registrationsTrend']),
      ),
      topBuyers: _toList(
        data['topBuyers'],
      ).map((e) => TopBuyer.fromJson(_asMap(e))).toList(),
    );
  }
}

class UsersSummary {
  final int total;
  final int admins;
  final int clients;
  final int active;
  final int inactive;
  final int newInWindow;
  final int connectedInWindow;

  const UsersSummary({
    required this.total,
    required this.admins,
    required this.clients,
    required this.active,
    required this.inactive,
    required this.newInWindow,
    required this.connectedInWindow,
  });

  factory UsersSummary.fromJson(Map<String, dynamic> json) {
    return UsersSummary(
      total: _toInt(json['total']),
      admins: _toInt(json['admins']),
      clients: _toInt(json['clients']),
      active: _toInt(json['active']),
      inactive: _toInt(json['inactive']),
      newInWindow: _toInt(json['newInWindow']),
      connectedInWindow: _toInt(json['connectedInWindow']),
    );
  }
}

class RegistrationsTrend {
  final String groupBy;
  final int days;
  final DateTime? sinceDate;
  final List<RegistrationPoint> points;

  const RegistrationsTrend({
    required this.groupBy,
    required this.days,
    required this.sinceDate,
    required this.points,
  });

  factory RegistrationsTrend.fromJson(Map<String, dynamic> json) {
    return RegistrationsTrend(
      groupBy: _toString(json['groupBy'], fallback: 'day'),
      days: _toInt(json['days']),
      sinceDate: _toDateTime(json['sinceDate']),
      points: _toList(
        json['points'],
      ).map((e) => RegistrationPoint.fromJson(_asMap(e))).toList(),
    );
  }
}

class RegistrationPoint {
  final String period;
  final int users;

  const RegistrationPoint({required this.period, required this.users});

  factory RegistrationPoint.fromJson(Map<String, dynamic> json) {
    return RegistrationPoint(
      period: _toString(json['period']),
      users: _toInt(json['users']),
    );
  }
}

class TopBuyer {
  final String userId;
  final String nom;
  final String email;
  final bool actif;
  final int orders;
  final double totalSpent;
  final int booksBought;

  const TopBuyer({
    required this.userId,
    required this.nom,
    required this.email,
    required this.actif,
    required this.orders,
    required this.totalSpent,
    required this.booksBought,
  });

  factory TopBuyer.fromJson(Map<String, dynamic> json) {
    return TopBuyer(
      userId: _toString(json['userId']),
      nom: _toString(json['nom']),
      email: _toString(json['email']),
      actif: _toBool(json['actif']),
      orders: _toInt(json['orders']),
      totalSpent: _toDouble(json['totalSpent']),
      booksBought: _toInt(json['booksBought']),
    );
  }
}

class CategoryStat {
  final String? categorieId;
  final String nom;
  final String? slug;
  final int copiesSold;
  final double revenue;
  final int ordersCount;
  final int uniqueLivres;

  const CategoryStat({
    required this.categorieId,
    required this.nom,
    required this.slug,
    required this.copiesSold,
    required this.revenue,
    required this.ordersCount,
    required this.uniqueLivres,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      categorieId: _nullableToString(json['categorieId']),
      nom: _toString(json['nom']),
      slug: _nullableToString(json['slug']),
      copiesSold: _toInt(json['copiesSold']),
      revenue: _toDouble(json['revenue']),
      ordersCount: _toInt(json['ordersCount']),
      uniqueLivres: _toInt(json['uniqueLivres']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return <String, dynamic>{};
}

List<dynamic> _toList(dynamic value) {
  if (value is List) return value;
  return const [];
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _toString(dynamic value, {String fallback = ''}) {
  final parsed = value?.toString();
  if (parsed == null || parsed.isEmpty || parsed == 'null') {
    return fallback;
  }
  return parsed;
}

String? _nullableToString(dynamic value) {
  final parsed = value?.toString();
  if (parsed == null || parsed.isEmpty || parsed == 'null') {
    return null;
  }
  return parsed;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

DateTime? _toDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty || raw == 'null') {
    return null;
  }
  return DateTime.tryParse(raw);
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => _toString(item))
        .where((e) => e.isNotEmpty)
        .toList();
  }
  final single = _toString(value);
  return single.isEmpty ? const [] : [single];
}
