import 'package:nomvia/domain/entities/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTripById(String id);
  Future<List<Trip>> getTrendingTrips();
  Future<List<Trip>> getUpcomingTrips();
}
