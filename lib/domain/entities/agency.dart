import 'package:equatable/equatable.dart';

class Agency extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final String coverUrl;
  final String motto;
  final int completedTrips;
  final int communitySize;
  final int travellersServed;
  final double rating;
  final int yearsActive;
  final double cancellationRate;

  const Agency({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.coverUrl,
    required this.motto,
    required this.completedTrips,
    required this.communitySize,
    required this.travellersServed,
    required this.rating,
    required this.yearsActive,
    required this.cancellationRate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        coverUrl,
        motto,
        completedTrips,
        communitySize,
        travellersServed,
        rating,
        yearsActive,
        cancellationRate,
      ];
}
