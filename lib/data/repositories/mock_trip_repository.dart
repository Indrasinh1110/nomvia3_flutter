import 'package:nomvia/data/datasources/mock_data.dart';
import 'package:nomvia/domain/entities/trip.dart';
import 'package:nomvia/domain/repositories/trip_repository.dart';

class MockTripRepository implements TripRepository {
  @override
  Future<List<Trip>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return MockData.trips;
  }

  @override
  Future<Trip?> getTripById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return MockData.trips.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Trip>> getTrendingTrips() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.trips.take(5).toList();
  }

  @override
  Future<List<Trip>> getUpcomingTrips() async {
    // Return trips with future dates
    return MockData.trips.where((t) => t.departureDate.isAfter(DateTime.now())).toList();
  }
}
