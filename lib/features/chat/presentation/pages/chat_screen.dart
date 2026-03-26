import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nomvia/core/theme/app_theme.dart';
import 'package:nomvia/core/utils/image_helper.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Trip Rooms'),
              Tab(text: 'Agencies'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TripRoomsList(),
            _AgencyChatsList(),
            _FriendChatsList(),
          ],
        ),
      ),
    );
  }
}

class _TripRoomsList extends StatelessWidget {
  const _TripRoomsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.group, color: Colors.white),
          ),
          title: Text(index == 0 ? 'Weekend Escape to Udaipur' : 'Saputara Monsoon Trek'),
          subtitle: Text(index == 0 ? 'Rohan: Anyone carrying a DSLR?' : 'Krunal: What time is the pickup?'),
          trailing: const Text('10:30 AM', style: TextStyle(fontSize: 12)),
          onTap: () => context.push('/chat/room/t$index'),
        );
      },
    );
  }
}

class _AgencyChatsList extends StatelessWidget {
  const _AgencyChatsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        final agencyNames = ['Aravalli Trails Support', 'Saputara Summit Admin', 'Kutch Caravan Co.'];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.business)),
          title: Text(agencyNames[index]),
          subtitle: const Text('Your query has been resolved.'),
           trailing: const Text('Yesterday', style: TextStyle(fontSize: 12)),
           onTap: () => context.push('/chat/agency/a$index'),
        );
      },
    );
  }
}

class _FriendChatsList extends StatelessWidget {
  const _FriendChatsList();

  @override
  Widget build(BuildContext context) {
    // Realistic Gujarati Names
    final names = ['Rohan Shah', 'Devansh Mehta', 'Aarav Joshi', 'Krunal Trivedi', 'Nidhi Patel'];
    
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ImageHelper.loadAvatar('https://i.pravatar.cc/150?u=${index + 20}'), // Offset to get different avatars
          title: Text(names[index]),
          subtitle: const Text('Lets go!'),
           trailing: const Text('2 days ago', style: TextStyle(fontSize: 12)),
           onTap: () => context.push('/chat/friend/u$index'),
        );
      },
    );
  }
}
