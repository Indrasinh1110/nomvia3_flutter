import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomvia/features/home/presentation/providers/home_providers.dart';
import 'package:nomvia/features/home/presentation/widgets/trip_list_item.dart';

class TrendingTripCarousel extends ConsumerWidget {
  const TrendingTripCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingTripsAsync = ref.watch(trendingTripsProvider);

    return trendingTripsAsync.when(
      data: (trips) {
        return SizedBox(
          height: 380, // Increased height to accommodate the card content without overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Container(
                width: 300, // Fixed width for horizontal items
                margin: const EdgeInsets.only(right: 16),
                child: TripListItem(trip: trip),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox(),
    );
  }
}
