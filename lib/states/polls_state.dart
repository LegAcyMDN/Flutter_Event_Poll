import 'package:event_poll/configs.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/poll.dart'; // Assurez-vous que le chemin d'importation est correct
import '../models/user.dart'; // Assurez-vous que le chemin d'importation est correct

class PollsState extends ChangeNotifier {
  String? _authToken;
  List<Poll> _polls = [];

  List<Poll> get polls => _polls;

  void setAuthToken(String? token) {
    _authToken = token;
    notifyListeners();
  }

  Future<User?> _fetchCurrentUser () async {
    if (_authToken == null) return null;

    final response = await http.get(
      Uri.parse('${Configs.baseUrl}/users/me'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user information');
    }
  }

  Future<void> fetchPolls() async {
    if (_authToken == null) return;

    final response = await http.get(
      Uri.parse('${Configs.baseUrl}/polls'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _polls = data.map((poll) => Poll.fromJson(poll)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load polls');
    }
  }

  Future<Poll?> fetchPollById(String id) async {
    final user = await _fetchCurrentUser ();
    if (user == null || user.role != 'admin') {
      throw Exception('Only administrators can fetch polls by ID');
    }

    final response = await http.get(
      Uri.parse('${Configs.baseUrl}/polls/$id'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Poll.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load poll');
    }
  }

  Future<void> createPoll(Poll poll) async {
    final user = await _fetchCurrentUser ();
    if (user == null || user.role != 'admin') {
      throw Exception('Only administrators can create polls');
    }

    final response = await http.post(
      Uri.parse('${Configs.baseUrl}/polls'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(poll.toJson()),
    );

    if (response.statusCode == 201) {
      _polls.add(Poll.fromJson(json.decode(response.body)));
      notifyListeners();
    } else {
      throw Exception('Failed to create poll');
    }
  }

  Future<void> updatePoll(String id, Poll poll) async {
    final user = await _fetchCurrentUser ();
    if (user == null || user.role != 'admin') {
      throw Exception('Only administrators can update polls');
    }

    final response = await http.put(
      Uri.parse('${Configs.baseUrl}/polls/$id'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(poll.toJson()),
    );

    if (response.statusCode == 200) {
      // Mettre à jour le sondage dans la liste
      final index = _polls.indexWhere((p) => p.id == id);
      if (index != -1) {
        _polls[index] = Poll.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update poll');
    }
  }

  Future<void> deletePoll(String id) async {
    final user = await _fetchCurrentUser ();
    if (user == null || user.role != 'admin') {
      throw Exception('Only administrators can delete polls');
    }

    final response = await http.delete(
      Uri.parse('${Configs.baseUrl}/polls/$id'), // Remplacez par votre URL d'API
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      // Supprimer le sondage de la liste
      _polls.removeWhere((poll) => poll.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete poll');
    }
  }
}