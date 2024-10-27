import 'package:didipartner/view/screens/rooms/room_details_update.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../res/components/LinearProgramindicator.dart';
import '../../../res/components/indicator.dart';
import '../../../utils/constant/contants.dart';
import '../../../view_model/provider/provider.dart';

class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  Future<List<Map<String, dynamic>>> fetchRooms() async {
    try {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      final roomIds = ap.ownerModel.roomId;

      List<Map<String, dynamic>> roomDetails = [];

      for (String roomId in roomIds) {
        DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
            .collection('Rooms')
            .doc(roomId)
            .get();

        if (roomSnapshot.exists) {
          Map<String, dynamic> roomData =
              roomSnapshot.data() as Map<String, dynamic>;
          roomData['roomId'] = roomId; // Add the roomId to the room data
          roomDetails.add(roomData);
        }
      }
      return roomDetails;
    } catch (error) {
      print('Error fetching rooms: $error');
      throw 'Error fetching rooms';
    }
  }

  Future<void> _refreshRooms() async {
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        shadowColor: AppColors.darkGray,
        surfaceTintColor: AppColors.white,

        title: Text('Rooms', style: AppTextStyles.headingStyleBold),
        backgroundColor: AppColors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  LoadingContainer(),
                  LoadingContainer(),
                  LoadingContainer(),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: AppTextStyles.subheadingStyleLight),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No rooms available',
                  style: AppTextStyles.subheadingStyleLight),
            );
          } else {
            final rooms = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshRooms,
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final roomId = room['roomId']; // Get roomId from room data
                  return RoomCard(
                      room: room, roomId: roomId); // Pass roomId to RoomCard
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final String roomId;

  RoomCard({required this.room, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(roomId: roomId),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(12),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            if (room['imageUrl'] != null && room['imageUrl'].isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: AppColors.lightGray,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: PageView.builder(
                    itemCount: room['imageUrl'].length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        room['imageUrl'][index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: AppColors.lightGray,
                child: Center(
                  child: Icon(Icons.image, size: 50, color: AppColors.darkGray),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Type and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(room['roomType'] ?? 'Room Type',
                          style: AppTextStyles.headingStyleBold),
                      Text("Rs ${room['price'] ?? 'N/A'}/night",
                          style: AppTextStyles.headingStyleBold
                              .copyWith(color: AppColors.primaryGreen)),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Location Info
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: AppColors.primaryGreen),
                      SizedBox(width: 5),
                      Text(
                        '${room['location']['city'] ?? 'Unknown'}, ${room['location']['state'] ?? ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Services Section
                  Text(
                    'Services',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  _buildServiceIcons(room['Services'] ?? {}),
                  SizedBox(height: 15),

                  // Number of Rooms
                  Text(
                    'No of Rooms: ${room['rooms'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcons(Map<String, dynamic> services) {
    List<Widget> serviceWidgets = [];

    services.forEach((service, available) {
      serviceWidgets.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  available ? Icons.check_circle : Icons.remove_circle_outline,
                  color: available ? AppColors.primaryGreen : Colors.redAccent,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  service,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Divider(height: 15, color: Colors.grey[300]), // Add divider
          ],
        ),
      );
    });

    return Column(
      children: serviceWidgets,
    );
  }
}
