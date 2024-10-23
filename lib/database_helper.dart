import 'dart:async';
import 'package:aquarium/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table to store overall settings
        await db.execute('''
        CREATE TABLE settings(
          id INTEGER PRIMARY KEY,
          fish_count INTEGER,
          speed REAL,
          color INTEGER
        )
      ''');

        // Table to store individual fish attributes
        await db.execute('''
        CREATE TABLE fish(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          x REAL,
          y REAL,
          speed REAL,
          color INTEGER
        )
      ''');
      },
    );
  }

  Future<void> saveSettings(int fishCount, double speed, int color) async {
    final db = await database;

    // Check if settings already exist
    final existingSettings = await db.query('settings', limit: 1);

    if (existingSettings.isNotEmpty) {
      // Update existing row
      await db.update(
        'settings',
        {
          'fish_count': fishCount,
          'speed': speed,
          'color': color,
        },
        where: 'id = ?',
        whereArgs: [existingSettings.first['id']],
      );
    } else {
      // Insert new settings row if none exist
      await db.insert(
        'settings',
        {
          'fish_count': fishCount,
          'speed': speed,
          'color': color,
        },
      );
    }
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> settings =
        await db.query('settings', limit: 1);
    return settings.isNotEmpty ? settings.first : null;
  }

  // Save individual fish attributes
  Future<void> saveFish(List<Fish> fishList) async {
    final db = await database;
    await db.delete('fish'); // Clear previous fish data

    for (var fish in fishList) {
      await db.insert(
        'fish',
        {
          'x': fish.x,
          'y': fish.y,
          'speed': fish.speed,
          'color': fish.color.value, // Store color as an integer value
        },
      );
    }
  }

  // Load individual fish attributes
  Future<List<Fish>> loadFish() async {
    final db = await database;
    final List<Map<String, dynamic>> fishData = await db.query('fish');

    return fishData.map((fish) {
      return Fish(
        x: fish['x'],
        y: fish['y'],
        speed: fish['speed'],
        color: Color(fish['color']), // Convert the integer to a Color
      );
    }).toList();
  }
}
