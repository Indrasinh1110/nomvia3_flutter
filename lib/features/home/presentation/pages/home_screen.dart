import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/features/home/presentation/providers/home_providers.dart';
import 'package:nomvia/features/home/presentation/widgets/friend_activity_list.dart';
import 'package:nomvia/features/home/presentation/widgets/trending_trip_carousel.dart';
import 'package:nomvia/features/home/presentation/widgets/trip_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use filteredTripsProvider instead of allTripsProvider
    final tripsAsync = ref.watch(filteredTripsProvider);
    final currentFilter = ref.watch(tripFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Icon(Icons.explore, color: AppTheme.primaryColor), 
              const SizedBox(width: 8),
              Text(
                'NOMVIA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFilterModal(context, ref),
        label: const Text('Filter'),
        icon: const Icon(Icons.filter_list),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(allTripsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Friends Travelling',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const FriendActivityList(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Trending Now',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TrendingTripCarousel(),
                  const SizedBox(height: 24),
                  
                  // Category Chips Row (Connected to Filter)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, ref, 'All', currentFilter.category == 'All'),
                          _buildFilterChip(context, ref, 'Adventure', currentFilter.category == 'Adventure'),
                          _buildFilterChip(context, ref, 'Relaxation', currentFilter.category == 'Relaxation'),
                          _buildFilterChip(context, ref, 'Cultural', currentFilter.category == 'Cultural'),
                          _buildFilterChip(context, ref, 'Family', currentFilter.category == 'Family'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended for You',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (currentFilter.category != 'All' || currentFilter.maxPrice != null)
                          TextButton(
                            onPressed: () => ref.read(tripFilterProvider.notifier).reset(),
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            tripsAsync.when(
              data: (trips) => trips.isEmpty 
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('No trips match your filters.'),
                        ),
                      ),
                    )
                  : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = trips[index];
                      return TripListItem(trip: trip);
                    },
                    childCount: trips.length,
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $err'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
             ref.read(tripFilterProvider.notifier).update((state) => state.copyWith(category: label));
          }
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
           side: isSelected ? BorderSide.none : const BorderSide(color: Colors.grey, width: 0.5),
        ),
        showCheckmark: false,
      ),
    );
  }

  void _showFilterModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final filter = ref.watch(tripFilterProvider);
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Budget
                      Text('Max Budget', style: Theme.of(context).textTheme.titleMedium),
                      Slider(
                        value: filter.maxPrice ?? 50000,
                        min: 5000,
                        max: 100000,
                        divisions: 19,
                        label: '₹${(filter.maxPrice ?? 50000).toInt()}',
                        onChanged: (val) {
                          ref.read(tripFilterProvider.notifier).update((state) => state.copyWith(maxPrice: val));
                        },
                      ),
                      Text('Up to ₹${(filter.maxPrice ?? 50000).toInt()}'),
                      
                      const SizedBox(height: 24),
                      
                      // Duration
                      Text('Duration (Days)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDurationChip(ref, filter, 'Short (1-3)', 1, 3),
                          _buildDurationChip(ref, filter, 'Medium (4-7)', 4, 7),
                          _buildDurationChip(ref, filter, 'Long (8+)', 8, 30),
                        ],
                      ),

                      const SizedBox(height: 24),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref.read(tripFilterProvider.notifier).reset();
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Apply logic is inherent as we updated state directly. 
                                // Just close modal.
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDurationChip(WidgetRef ref, TripFilter filter, String label, int min, int max) {
    final isSelected = filter.minDuration == min && filter.maxDuration == max;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
           if (selected) {
             ref.read(tripFilterProvider.notifier).update((state) => state.copyWith(minDuration: min, maxDuration: max));
           } else {
             ref.read(tripFilterProvider.notifier).update((state) => state.copyWith(minDuration: null, maxDuration: null));
           }
        },
      ),
    );
  }
}
