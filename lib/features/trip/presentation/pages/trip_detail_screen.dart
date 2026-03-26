import 'package:flutter/material.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nomvia/core/constants/app_constants.dart';
import 'package:nomvia/core/providers.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/domain/entities/trip.dart';
import 'package:intl/intl.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final Trip? trip;

  const TripDetailScreen({super.key, required this.tripId, this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Trip? _trip;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _trip = widget.trip;
    } else {
      // Fetch if not provided (deep link simulation)
      ref.read(tripRepositoryProvider).getTripById(widget.tripId).then((t) {
        if (mounted) setState(() => _trip = t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final trip = _trip!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageHelper.loadNetworkImage(
                trip.imageUrls.first,
                fit: BoxFit.cover,
                fallbackAsset: 'assets/images/trip_placeholder.png',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          trip.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.durationDays} Days • ${DateFormat('d MMM').format(trip.departureDate)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: AppTheme.accentColor, size: 18),
                      const Text(' 4.8 (120 reviews)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total Seats', '${trip.totalSeats}'),
                      _buildVerticalDivider(),
                      _buildStatItem('Available', '${trip.availableSeats}'),
                      _buildVerticalDivider(),
                      _buildStatItem('Booked', '${trip.friendsBookedCount > 0 ? (trip.totalSeats - trip.availableSeats) : 0}'), // Dummy math or from bookedUsers
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Agency Info - Clickable
                  GestureDetector(
                    onTap: () => context.push('/agency/${trip.agency.id}', extra: trip.agency),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          ImageHelper.loadAvatar(trip.agency.logoUrl, radius: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trip.agency.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(trip.agency.motto, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // People Going
                  if (trip.bookedUsers.isNotEmpty) ...[
                    Text('People Going', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: trip.bookedUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final user = trip.bookedUsers[index];
                          // Check if "Your Friend" - simplistic check, assume friend list in mock data refers to current user friends
                          final isFriend = true; // In mock data, bookedUsers came from friends list
                          
                          return GestureDetector(
                            onTap: () => context.push('/profile/${user.id}', extra: user),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ImageHelper.loadAvatar(user.profileImageUrl, radius: 25),
                                if (isFriend)
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: const Icon(Icons.favorite, size: 12, color: Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text('About this trip', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    trip.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.grey[800]),
                  ),

                  const SizedBox(height: 24),
                  Text('Itinerary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildItineraryItem(1, 'Arrival & Welcome', 'Check-in and briefing session.'),
                  _buildItineraryItem(2, 'Exploration', 'Full day sightseeing and activities.'),
                  if (trip.durationDays > 2)
                    _buildItineraryItem(3, 'Departure', 'Breakfast and checkout.'),

                  const SizedBox(height: 24),
                  Text('What\'s Included', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: trip.inclusions.map((inc) => Chip(
                      label: Text(inc),
                      backgroundColor: Colors.grey[100],
                      avatar: const Icon(Icons.check, size: 16, color: Colors.green),
                    )).toList(),
                  ),

                   const SizedBox(height: 24),
                  Text('Cancellation Policy', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(trip.cancellationPolicy, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${NumberFormat('#,##,###').format(trip.price)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'per person',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.push('/booking/kyc/${trip.id}');
              },
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildItineraryItem(int day, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
