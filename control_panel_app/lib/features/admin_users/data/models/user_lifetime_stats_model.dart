import '../../domain/entities/user_lifetime_stats.dart';

class UserLifetimeStatsModel extends UserLifetimeStats {
  const UserLifetimeStatsModel({
    required int totalNightsStayed,
    required double totalMoneySpent,
    String? favoriteCity,
  }) : super(
          totalNightsStayed: totalNightsStayed,
          totalMoneySpent: totalMoneySpent,
          favoriteCity: favoriteCity,
        );

  factory UserLifetimeStatsModel.fromJson(Map<String, dynamic> json) {
    return UserLifetimeStatsModel(
      totalNightsStayed: json['totalNightsStayed'] as int,
      totalMoneySpent: (json['totalMoneySpent'] as num).toDouble(),
      favoriteCity: json['favoriteCity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNightsStayed': totalNightsStayed,
      'totalMoneySpent': totalMoneySpent,
      'favoriteCity': favoriteCity,
    };
  }
}