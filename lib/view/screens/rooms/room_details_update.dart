import 'package:didipartner/view_model/provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../res/components/LinearProgramindicator.dart';
import '../../../res/components/indicator.dart';
import '../../../utils/constant/contants.dart';
import '../../../utils/utils.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  RoomDetailScreen({required this.roomId});

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late TextEditingController _priceController;
  bool _isEditingPrice = false;
  late Map<String, dynamic> _services;
  late Map<String, dynamic> _roomAvailability;
  DateTimeRange? _selectedDateRange;
  List<Map<String, dynamic>> _availabilityList = [];
  Map<String, dynamic>? _roomDetails;
  late int roomPrice;
  int roomCount = 1;
  int maxRoomCount = 10; // Maximum available rooms
  int maxRooms = 10; // Maximum available rooms


  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _services = {};
    _roomAvailability = {};
    _fetchRoomDetails();
  }

  Future<void> _fetchRoomDetails() async {
    DocumentSnapshot roomDoc = await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(widget.roomId)
        .get();

    if (roomDoc.exists) {
      setState(() {
        _roomDetails = roomDoc.data() as Map<String, dynamic>;
        _priceController.text = _roomDetails!['price'].toString();
        _services = Map<String, dynamic>.from(_roomDetails!['Services'] ?? {});
        _roomAvailability =
            Map<String, dynamic>.from(_roomDetails!['roomAvailability'] ?? {});
      });
    }
  }

  void _updateAvailabilityForDateRange(DateTimeRange dateRange) {
    List<Map<String, dynamic>> availability = [];

    for (DateTime date = dateRange.start;
        date.isBefore(dateRange.end.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      int rooms = int.parse(_roomDetails!['rooms']);
      int availableRooms = int.tryParse(
              _roomAvailability[formattedDate]?['available'].toString() ??
                  _roomDetails!['rooms']) ??
          0;

      // Fetching the customer IDs for the current date
      List<dynamic> customerIds =
          _roomAvailability[formattedDate]?['IDs'] ?? [];

      // Ensure customerIds are treated as strings
      List<String> stringCustomerIds = List<String>.from(customerIds);
      if(maxRooms>availableRooms){
        maxRooms=availableRooms;
      }

      availability.add({
        'date': formattedDate,
        'available': availableRooms,
        'booked': rooms - availableRooms,
        'IDs': stringCustomerIds, // Adding IDs as strings
      });
    }

    setState(() {
      _availabilityList = availability;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _updateAvailabilityForDateRange(picked);
    }
  }

  Future<void> _savePrice() async {
    try {
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomId)
          .update({'price': int.parse(_priceController.text)});
      setState(() {
        _isEditingPrice = false;
      });
    } catch (error) {
      print("Failed to update price: $error");
    }
  }

  Future<void> _toggleService(String service) async {
    setState(() {
      _services[service] = !_services[service];
    });
    try {
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomId)
          .update({'Services': _services});
    } catch (error) {
      print("Failed to update services: $error");
    }
  }

// Inside your _RoomDetailScreenState class
  void _onDateTap(String date, Map<String, dynamic> roomAvailability,
      String ownerId) async {
    // Accessing IDs for the specific date
    List<String> customerIds = List<String>.from(roomAvailability['IDs'] ?? []);

    // Extract the roomId from roomAvailability
    String roomId =
        widget.roomId; // Assuming roomId is stored in roomAvailability

    if (customerIds.isNotEmpty) {
      List<Map<String, dynamic>> bookings =
          await _fetchBookingDetailsForDate(customerIds, roomId, ownerId);
      if (bookings.isNotEmpty) {
        _showBookingDetailsDialog(bookings);
      } else {
        _showNoBookingsDialog();
      }
    } else {
      _showNoBookingsDialog();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchBookingDetailsForDate(
      List<String> customerIds, String roomId, String ownerId) async {
    // Initialize the Firebase reference to the owner's bookings
    DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('Bookings').child(ownerId);

    // Fetch all bookings under the ownerId
    DatabaseEvent event = await bookingsRef.once();

    List<Map<String, dynamic>> relevantBookings = [];

    if (event.snapshot.value != null) {
      // Convert the fetched data to a Map
      Map<dynamic, dynamic> bookingsData =
          event.snapshot.value as Map<dynamic, dynamic>;

      // Loop through all bookings under the owner
      bookingsData.forEach((bookingKey, bookingDetails) {
        // Check if the booking's CustomerId and RoomId matches
        if (customerIds.contains(bookingDetails['CustomerId'].toString()) &&
            bookingDetails['roomId'] == roomId) {
          relevantBookings
              .add(Map<String, dynamic>.from(bookingDetails as Map));
        }
      });
    }

    return relevantBookings;
  }

  void _showBookingDetailsDialog(List<Map<String, dynamic>> bookings) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.backgroundcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.white,
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Booking Details',
                  style: AppTextStyles.headingStyleBold,
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  child: Column(
                    children: bookings.map((booking) {
                      return GestureDetector(
                        onTap: () {
                          // Handle tap if needed
                        },
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer ID: ${booking['CustomerId']}',
                                  style: AppTextStyles.subheadingStyleLight,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rooms: ${booking['numberOfRooms']}',
                                  style: AppTextStyles.subheadingStyleLight,
                                ),
                                Text(
                                  'Price: ${booking['totalPrice']}',
                                  style: AppTextStyles.subheadingStyleLight,
                                ),
                                Text(
                                  'Start: ${booking['startDate']}',
                                  style: AppTextStyles.subheadingStyleLight,
                                ),
                                Text(
                                  'End: ${booking['endDate']}',
                                  style: AppTextStyles.subheadingStyleLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoBookingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Bookings'),
          content: Text('No bookings found for the selected date.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showServiceEditDialog(String service) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Available'),
                value: _services[service] as bool,
                onChanged: (value) {
                  _toggleService(service);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> bookNow() async {
    if (_selectedDateRange == null) {
      showSnackBar(context, 'Please select a date range first.');
      return;
    }

    setState(() {

    });

    final int totalDays = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
    final ap = Provider.of<AuthProvider>(context, listen: false);
    bool canBook = true;

    // Check room availability for each date in the selected range
    for (DateTime date = _selectedDateRange!.start;
    date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
    date = date.add(Duration(days: 1))) {
      int availableForDate = _roomAvailability[DateFormat('yyyy-MM-dd').format(date)]?['available'] ?? maxRoomCount;

      if (availableForDate < roomCount) {
        canBook = false;
        setState(() {

        });
        showSnackBar(context, 'Not enough rooms available for the selected dates!');
        return;
      }
    }

    if (canBook) {
      try {
        DocumentReference roomRef = FirebaseFirestore.instance.collection('Rooms').doc(widget.roomId);
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Update room availability for each date in the selected range
        for (DateTime date = _selectedDateRange!.start;
        date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
          String dateKey = DateFormat('yyyy-MM-dd').format(date);

          // Fetch existing IDs and availability for the date
          List<dynamic> existingIDs = List<dynamic>.from(_roomAvailability[dateKey]?['IDs'] ?? []);
          int currentAvailable = _roomAvailability[dateKey]?['available'] ?? maxRoomCount;



          // Update availability map with the reduced room count and modified IDs
          batch.update(roomRef, {
            'roomAvailability.$dateKey': {
              'available': currentAvailable - roomCount,
            }
          });
        }

        // Commit the batch update
        await batch.commit();
        showSnackBar(context, 'Booking successful!');
        setState(() {

        });
      } catch (e) {
        setState(() {

        });
        showSnackBar(context, 'Booking failed! Please try again.');
      }
    }
  }void _showBookingDialog() {
    if (_selectedDateRange == null) {
      showSnackBar(context, "Please select a date range first.");
      return;
    }

    int roomCount = 1; // Initial room count
    int maxRoomsAvailable = maxRooms;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Booking Details",
                          style: AppTextStyles.headingStyleBold.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)}",
                            style: AppTextStyles.subheadingStyle,
                          ),
                          Text(
                            "To: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}",
                            style: AppTextStyles.subheadingStyle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select Rooms:", style: AppTextStyles.bodyTextStyle),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: AppColors.primaryGreen, size: 30),
                              onPressed: () {
                                if (roomCount > 1) {
                                  setState(() {
                                    roomCount--;
                                  });
                                }
                              },
                            ),
                            Text(
                              "$roomCount",
                              style: AppTextStyles.subheadingbold.copyWith(fontSize: 18),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: AppColors.primaryGreen, size: 30),
                              onPressed: () {
                                if (roomCount < maxRoomsAvailable) {
                                  setState(() {
                                    roomCount++;
                                  });
                                } else {
                                  showSnackBar(context, "Maximum rooms available for this date range: $maxRoomsAvailable");
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "You are booking for $roomCount room(s) from ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.darkGray),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        bookNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        elevation: 5,
                      ),
                      child: Text(
                        "Confirm Booking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }







  @override
  Widget build(BuildContext context) {
    if (_roomDetails == null) {
      return Scaffold(
          backgroundColor: AppColors.backgroundcolor,
          appBar: AppBar(
            title: Text('Room Details', style: AppTextStyles.headingStyleBold),
            backgroundColor: AppColors.white,
          ),
          body: Column(
            children: [
              LoadingContainer(),
              LoadingContainer(),
              LoadingContainer(),
              LoadingContainer(),
              LoadingContainer(),
            ],
          ));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        shadowColor: AppColors.darkGray,
        surfaceTintColor: AppColors.white,
        title: Text('Room Details', style: AppTextStyles.headingStyleBold),
        backgroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: ListView(
          children: [
            _buildImageCarousel(),
            SizedBox(height: 20),
            _buildRoomTypeAndPriceSection(),
            SizedBox(height: 20),
            _buildLocationInfo(),
            SizedBox(height: 20),
            _buildServicesSection(),
            SizedBox(height: 20),
            _buildRoomAvailabilitySection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return _roomDetails!['imageUrl'] != null &&
            _roomDetails!['imageUrl'].isNotEmpty
        ? Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4)),
              ],
            ),
            child: PageView.builder(
              itemCount: _roomDetails!['imageUrl'].length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _roomDetails!['imageUrl'][index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          )
        : Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.image, size: 50, color: AppColors.darkGray),
            ),
          );
  }

  Widget _buildRoomTypeAndPriceSection() {
    return Card(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _roomDetails!['roomType'] ?? 'Room Type',
              style: AppTextStyles.headingStyleBold,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isEditingPrice
                  ? SizedBox(
                      key: ValueKey(1),
                      width: 120,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.check,
                                color: AppColors.primaryGreen),
                            onPressed: _savePrice,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      key: ValueKey(2),
                      children: [
                        Text(
                          "Rs ${_roomDetails!['price']}/night",
                          style: AppTextStyles.subheadingbold.copyWith(
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                            width: 8), // Add some space between text and icon
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.primaryGreen),
                          onPressed: () {
                            setState(() {
                              _isEditingPrice = true;
                            });
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.location_on, size: 18, color: AppColors.primaryGreen),
            SizedBox(width: 5),
            Text(
              '${_roomDetails!['location']['city'] ?? 'Unknown'}, ${_roomDetails!['location']['state'] ?? ''}',
              style: AppTextStyles.subheadingStyleLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services',
              style: AppTextStyles.subheadingbold.copyWith(fontSize: 18),
            ),
            SizedBox(height: 10),
            _buildServiceButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomAvailabilitySection() {
    return Card(
      elevation: 4,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Availability',
              style: AppTextStyles.subheadingbold.copyWith(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDateRange(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedDateRange != null
                    ? 'Selected Dates: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}'
                    : 'Select Date Range',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showBookingDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reserve',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            if (_availabilityList.isNotEmpty) _buildAvailabilityDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityDisplay() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      children: _availabilityList.map((availability) {
        // Check if available is greater than 0
        bool isClickable = availability['booked'] > 0;

        return Container(
          child: isClickable
              ? InkWell(
                  onTap: () {
                    _onDateTap(
                        availability['date'], availability, ap.ownerModel.uid);
                  },
                  child: _buildAvailabilityCard(availability),
                )
              : _buildAvailabilityCard(
                  availability), // Render card without tap action
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilityCard(Map<String, dynamic> availability) {
    return Card(
      color: AppColors.white,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              availability['date'],
              style: AppTextStyles.subheadingStyleLight,
            ),
            Column(
              children: [
                availability['booked'] > 0
                    ? Text(
                        '${availability['booked']} booking   >',
                        style: AppTextStyles.subheadingStyleLight
                            .copyWith(color: Colors.green),
                      )
                    : Text(
                        'No booking',
                        style: AppTextStyles.subheadingStyleLight
                            .copyWith(color: Colors.red),
                      ),
                availability['available'] > 0
                    ? Text(
                        '${availability['available']} Available',
                        style: AppTextStyles.subheadingStyleLight
                            .copyWith(color: Colors.green),
                      )
                    : Text(
                        'No booking',
                        style: AppTextStyles.subheadingStyleLight
                            .copyWith(color: Colors.red),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButtons() {
    return Wrap(
      spacing: 8.0,
      children: _services.keys.map((service) {
        return ElevatedButton(
          onPressed: () => _showServiceEditDialog(service),
          style: ElevatedButton.styleFrom(
            backgroundColor: _services[service]
                ? AppColors.primaryGreen
                : AppColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _services[service]
              ? Text(
                  service,
                  style: AppTextStyles.subheadingStyle
                      .copyWith(color: Colors.white),
                )
              : Text(
                  service,
                  style: AppTextStyles.subheadingStyle,
                ),
        );
      }).toList(),
    );
  }
}
