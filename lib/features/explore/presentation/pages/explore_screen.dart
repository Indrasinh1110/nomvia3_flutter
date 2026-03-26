import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomvia/core/constants/app_constants.dart';
import 'package:nomvia/data/datasources/mock_data.dart';
import 'package:nomvia/core/utils/image_helper.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/features/agency/presentation/widgets/agency_list_item.dart';
import 'package:nomvia/features/home/presentation/widgets/trip_list_item.dart';
import 'package:go_router/go_router.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search trips, agencies, people...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              filled: false,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trips'),
            Tab(text: 'Agencies'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripsList(),
          _buildAgenciesList(),
          _buildPeopleList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterModal,
        label: const Text('Filter'),
        icon: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: MockData.trips.length,
      itemBuilder: (context, index) => TripListItem(trip: MockData.trips[index]),
    );
  }

  Widget _buildAgenciesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: MockData.agencies.length,
      separatorBuilder: (c, i) => const Divider(),
      itemBuilder: (context, index) => AgencyListItem(agency: MockData.agencies[index]),
    );
  }

  Widget _buildPeopleList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: MockData.friends.length,
      separatorBuilder: (c, i) => const Divider(),
      itemBuilder: (context, index) {
        final user = MockData.friends[index];
        return ListTile(
          onTap: () => context.push('/profile/${user.id}', extra: user), // Navigate to specific profile with data
          leading: ImageHelper.loadAvatar(user.profileImageUrl),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.person_add_outlined, color: AppTheme.primaryColor),
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
                   IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              
              Text('Trip Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Adventure', 'Cultural', 'Relaxation', 'Family', 'Spiritual'].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: false,
                    onSelected: (val) {},
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              Text('Price Range', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              RangeSlider(
                values: const RangeValues(2000, 10000),
                min: 1000,
                max: 20000,
                divisions: 10,
                labels: const RangeLabels('₹2k', '₹10k'),
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {},
              ),

               const SizedBox(height: 24),
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
               Wrap(
                spacing: 8,
                children: const [
                  ChoiceChip(label: Text('1-3 Days'), selected: true),
                  ChoiceChip(label: Text('4-7 Days'), selected: false),
                  ChoiceChip(label: Text('7+ Days'), selected: false),
                ],
              ),
              
              const SizedBox(height: 24),
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: const Text('Select Location'),
                items: ['Ahmedabad', 'Udaipur', 'Saputara', 'Kutch'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {},
              ),

              const SizedBox(height: 40),
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.pop(context);
                     // Simulate filtering feedback
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters applied')));
                   }, 
                   child: const Text('Apply Filters')
                 ),
               ),
               const SizedBox(height: 16),
               Center(
                 child: TextButton(
                   onPressed: () {},
                   child: const Text('Reset', style: TextStyle(color: Colors.grey)),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
