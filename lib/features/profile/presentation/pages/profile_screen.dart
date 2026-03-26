import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:nomvia/domain/entities/trip.dart';
import 'package:nomvia/domain/entities/user.dart';
import 'package:nomvia/features/home/presentation/providers/home_providers.dart';
import 'package:nomvia/features/home/presentation/widgets/trip_list_item.dart';
import 'package:nomvia/core/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTabIndex = 0; // 0: Trips, 1: My Plan

  @override
  Widget build(BuildContext context) {
    // If userId is provided, we should ideally fetch that user. 
    // For prototype, if userId is null, use currentUser. 
    // If userId is present, we try to find it in MockData or just use currentUser for demo if not found.
    // In a real app, this would be a repository call.
    final User? extraUser = GoRouterState.of(context).extra as User?;
    final AsyncValue<User> userAsync = extraUser != null 
        ? AsyncData(extraUser) 
        : ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(extraUser != null ? 'Profile' : 'My Profile'), // Change title based on context
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              // Logout logic
              await ref.read(authServiceProvider).signOut();
              // Router handles redirection to login
            }, 
            icon: const Icon(Icons.logout)
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 24),
              _buildStats(user),
              const SizedBox(height: 24),
              _buildToggleTabs(),
              const SizedBox(height: 24),
              _selectedTabIndex == 0 ? _buildTimelineSection(user) : _buildMyPlanSection(user),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          ImageHelper.loadAvatar(user.profileImageUrl, radius: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${user.username} • ${user.travellerType}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(user.bio),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Trips Done', '${user.tripsDoneCount}'),
          _buildStatItem('Friends', '${user.friendsCount}'),
          // Calculated from saved trips for realism
          _buildStatItem('Bucket List', '${user.savedTrips.length}'), 
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildTabButton('Trips', 0),
            _buildTabButton('My Plan', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.upcomingTrips.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('UPCOMING', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2, color: Colors.grey)),
          ),
          ...user.upcomingTrips.map((trip) => _TimelineItem(trip: trip, isPast: false)),
        ],
        
        if (user.completedTrips.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('PAST', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2, color: Colors.grey)),
          ),
          ...user.completedTrips.map((trip) => _TimelineItem(trip: trip, isPast: true)),
        ],
      ],
    );
  }

  Widget _buildMyPlanSection(User user) {
    if (user.savedTrips.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('No saved trips in your plan yet.'),
      ));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: user.savedTrips.length,
      itemBuilder: (context, index) {
        return TripListItem(trip: user.savedTrips[index]);
      },
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final Trip trip;
  final bool isPast;

  const _TimelineItem({required this.trip, required this.isPast});

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: widget.isPast ? Colors.grey : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24, right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.trip.title, // Destination generally in title
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (!widget.isPast)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.trip.durationDays} Days',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(widget.trip.departureDate),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.trip.description,
                        style: TextStyle(color: Colors.grey[800], height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                         onTap: () => context.push('/trip/${widget.trip.id}', extra: widget.trip),
                         child: const Text('View Details', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
