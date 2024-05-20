import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zendiet/screens/add_post_screen.dart';
import 'package:zendiet/screens/calculate_screen.dart';
import 'package:zendiet/screens/calendar_screen.dart';
import 'package:zendiet/screens/feed_screen.dart';
import 'package:zendiet/screens/profile_screen.dart';
import 'package:zendiet/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const Text('notifications'),
  const AddPostScreen(),
  const CalendarScreen(),
  const CalculateScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
