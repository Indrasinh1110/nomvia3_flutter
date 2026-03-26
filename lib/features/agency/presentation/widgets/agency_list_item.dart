import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:nomvia/domain/entities/agency.dart';

class AgencyListItem extends StatelessWidget {
  final Agency agency;

  const AgencyListItem({super.key, required this.agency});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/agency/${agency.id}', extra: agency),
      leading: ImageHelper.loadAvatar(agency.logoUrl, radius: 24),
      title: Text(agency.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${agency.motto}\n${agency.rating} ★  • ${agency.completedTrips} Trips'),
      isThreeLine: true,
      trailing: ElevatedButton(
        onPressed: () => context.push('/agency/${agency.id}', extra: agency),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: const Size(60, 32),
        ),
        child: const Text('View'),
      ),
    );
  }
}
