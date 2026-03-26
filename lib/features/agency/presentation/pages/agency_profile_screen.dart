import 'package:flutter/material.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/domain/entities/agency.dart';

class AgencyProfileScreen extends StatelessWidget {
  final String agencyId;
  final Agency? agency;

  const AgencyProfileScreen({super.key, required this.agencyId, this.agency});

  @override
  Widget build(BuildContext context) {
    if (agency == null) return const Scaffold(body: Center(child: Text('Agency not found')));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageHelper.loadNetworkImage(
                agency!.coverUrl,
                fit: BoxFit.cover,
                fallbackAsset: 'assets/images/trip_placeholder.png', // Consistent fallback
              ),
              title: Text(agency!.name),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ImageHelper.loadAvatar(agency!.logoUrl, radius: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(agency!.motto, style: const TextStyle(fontStyle: FontStyle.italic)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' ${agency!.rating} • ${agency!.yearsActive} Years Active'),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('Trips', '${agency!.completedTrips}'),
                      _statItem('Community', '${agency!.communitySize}'),
                      _statItem('Travellers', '${agency!.travellersServed}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Community'))),
                      const SizedBox(width: 16),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Query'))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Trust Stack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.verified, color: AppTheme.primaryColor),
                    title: const Text('Verified Agency'),
                    subtitle: Text('Cancellation Rate: ${agency!.cancellationRate}%'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
