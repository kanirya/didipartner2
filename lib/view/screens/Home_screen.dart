import 'package:didipartner/res/components/LinearProgramindicator.dart';
import 'package:didipartner/utils/constant/contants.dart';
import 'package:didipartner/view/screens/profile/main_profile.dart';
import 'package:didipartner/view/screens/rooms/Rooms.dart';
import 'package:didipartner/view_model/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'BookingDetails/details.dart';
import 'Home/home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for Bottom Navigation Bar
  final List<Widget> _screens = [
    Home(), // Home screen
    BookingListScreen(), // Favorites screen
    OrdersScreen(),
    RoomsScreen(),
    ProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGreen,

        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home), // Home icon
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboardList), // Favorites icon
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.briefcase), // Orders icon
            label: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bed), // Orders icon
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user), // Profile icon
            label: '',
          ),
        ],
      ),
    );
  }
}



class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ap=Provider.of<AuthProvider>(context,listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingContainer()
        ],
      ),
    );
  }
}

