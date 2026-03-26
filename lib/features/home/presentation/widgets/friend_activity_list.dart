import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:nomvia/domain/entities/user.dart';
import 'package:nomvia/features/home/presentation/providers/home_providers.dart';
import 'package:go_router/go_router.dart';

class FriendActivityList extends ConsumerWidget {
  const FriendActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      data: (friends) {
        // Filter friends with upcoming trips and sort/group by date
        final friendsWithTrips = friends.where((f) => f.upcomingTrips.isNotEmpty).toList();
        
        if (friendsWithTrips.isEmpty) return const SizedBox.shrink();

        // Sort by date
        friendsWithTrips.sort((a, b) => a.upcomingTrips.first.departureDate.compareTo(b.upcomingTrips.first.departureDate));

        // Group by date string (e.g., "14 Feb")
        final Map<String, List<User>> groupedFriends = {};
        for (var friend in friendsWithTrips) {
          final dateStr = DateFormat('d MMM').format(friend.upcomingTrips.first.departureDate);
          if (!groupedFriends.containsKey(dateStr)) {
            groupedFriends[dateStr] = [];
          }
          groupedFriends[dateStr]!.add(friend);
        }

        return SizedBox(
          height: 120, // Increased height for date label and avatar
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedFriends.keys.length,
            separatorBuilder: (context, index) => Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
            itemBuilder: (context, index) {
              final dateKey = groupedFriends.keys.elementAt(index);
              final groupFriends = groupedFriends[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      dateKey,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Row(
                    children: groupFriends.map((friend) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => context.push('/profile/${friend.id}', extra: friend),
                          child: Column(
                            children: [
                              ImageHelper.loadAvatar(
                                friend.profileImageUrl,
                                radius: 26,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                friend.name.split(' ').first,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                              Text(
                                friend.upcomingTrips.first.title.split(' ').last, // Destination hint
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox(),
    );
  }
}
