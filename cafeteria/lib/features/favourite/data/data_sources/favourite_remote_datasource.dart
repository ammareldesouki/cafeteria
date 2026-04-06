import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favourite_model.dart';

abstract class FavouriteRemoteDataSource {
  Future<List<FavouriteModel>> getFavourites();
  Future<void> addFavourite(String itemId);
  Future<void> removeFavourite(String itemId);
}

class FavouriteRemoteDataSourceImpl implements FavouriteRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String token; // pass your auth token here

  FavouriteRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  @override
  Future<List<FavouriteModel>> getFavourites() async {
    final response = await client.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => FavouriteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch favourites: ${response.statusCode}');
    }
  }

  @override
  Future<void> addFavourite(String itemId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
      body: json.encode({'itemId': itemId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add favourite: ${response.statusCode}');
    }
  }

  @override
  Future<void> removeFavourite(String itemId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/favorites/$itemId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove favourite: ${response.statusCode}');
    }
  }
}
