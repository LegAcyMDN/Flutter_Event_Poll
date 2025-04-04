import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../states/polls_state.dart';

class PollsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondages'),
      ),
      body: FutureBuilder(
        future: context.read<PollsState>().fetchPolls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final polls = context.watch<PollsState>().polls;

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return ListTile(
                title: Text(poll.name),
                subtitle: Text(poll.description),
                onTap: () {
                  // Naviguer vers la page de détails du sondage
                  Navigator.pushNamed(context, '/polls/detail', arguments: poll);
                },
              );
            },
          );
        },
      ),
    );
  }
}