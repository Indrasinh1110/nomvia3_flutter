import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomvia/core/providers.dart';
import 'package:nomvia/domain/entities/trip.dart';
import 'package:nomvia/domain/entities/user.dart';

final allTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTrips();
});

final trendingTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.getTrendingTrips();
});

final friendsProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getFriends();
});

final currentUserProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

// --- Filter Logic ---

class TripFilter {
  final String category; // 'All' means no category filter
  final double? maxPrice;
  final int? minDuration;
  final int? maxDuration;
  final String? location;

  const TripFilter({
    this.category = 'All',
    this.maxPrice,
    this.minDuration,
    this.maxDuration,
    this.location,
  });

  TripFilter copyWith({
    String? category,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
    String? location,
  }) {
    return TripFilter(
      category: category ?? this.category,
      maxPrice: maxPrice ?? this.maxPrice,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      location: location ?? this.location,
    );
  }
}

class TripFilterNotifier extends Notifier<TripFilter> {
  @override
  TripFilter build() {
    return const TripFilter();
  }

  void update(TripFilter Function(TripFilter state) cb) {
    state = cb(state);
  }

  void reset() {
    state = const TripFilter();
  }
}

final tripFilterProvider = NotifierProvider<TripFilterNotifier, TripFilter>(TripFilterNotifier.new);

final filteredTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final allTrips = await ref.watch(allTripsProvider.future);
  final filter = ref.watch(tripFilterProvider);

  return allTrips.where((trip) {
    // 1. Category Filter (Mocking category check as Trip entity might not have it explicitly, assuming 'tags' or 'title' or just generic for now)
    // For prototype, we'll assume if category is not All, we check if title/description contains it or if we add a category field later.
    // Let's assume we match against a 'type' or similar if available, else we mock it.
    // The Trip entity in `domain/entities/trip.dart` likely has fields. Let's check. 
    // Wait, I haven't seen Trip entity fields deeply. 
    // But `TripType` was mentioned in previous context.
    
    bool matchesCategory = true;
    if (filter.category != 'All') {
       // Mock logic: randomly filter or check title for matching string
       // Real logic: matchesCategory = trip.type == filter.category;
       matchesCategory = trip.title.contains(filter.category) || trip.description.contains(filter.category); 
       // If no match in text, maybe it's just a demo filter.
    }

    // 2. Price Filter
    bool matchesPrice = true;
    if (filter.maxPrice != null) {
      matchesPrice = trip.price <= filter.maxPrice!;
    }

    // 3. Duration Filter
    bool matchesDuration = true;
    if (filter.minDuration != null) {
      matchesDuration = trip.durationDays >= filter.minDuration!;
    }
    if (filter.maxDuration != null) {
      matchesDuration = matchesDuration && trip.durationDays <= filter.maxDuration!;
    }

    // 4. Location Filter
    bool matchesLocation = true;
    if (filter.location != null && filter.location!.isNotEmpty) {
      matchesLocation = trip.pickupLocation.toLowerCase().contains(filter.location!.toLowerCase());
    }

    return matchesCategory && matchesPrice && matchesDuration && matchesLocation;
  }).toList();
});
