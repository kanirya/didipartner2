import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:provider/provider.dart'; // For accessing AuthProvider
import 'package:google_fonts/google_fonts.dart';
import '../../../res/components/LinearProgramindicator.dart';
import '../../../utils/constant/contants.dart';
import '../../../view_model/provider/provider.dart';

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> bookingList = [];
  List<Map<dynamic, dynamic>> filteredBookings = [];
  bool isLoading = true;
  String searchQuery = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    DatabaseReference bookingsRef =
        databaseReference.child('Bookings').child(ap.ownerModel.uid);

    try {
      DatabaseEvent event = await bookingsRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> bookings =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<dynamic, dynamic>> tempBookingList = [];
        for (var entry in bookings.entries) {
          var booking = entry.value as Map<dynamic, dynamic>;
          if (booking['CustomerId'] != null) {
            var customerData =
                await fetchCustomerDetails(booking['CustomerId']);
            booking['customerDetails'] = customerData;
          }
          tempBookingList.add(booking);
        }
        setState(() {
          bookingList = tempBookingList;
          filteredBookings = bookingList;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchCustomerDetails(String customerId) async {
    try {
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('Customers')
          .doc(customerId)
          .get();
      if (customerSnapshot.exists) {
        return customerSnapshot.data() as Map<String, dynamic>?;
      }
    } catch (error) {
      print("Error fetching customer details: $error");
    }
    return null; // Return null if no data found
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchBookings();
  }

  void applyFilters() {
    setState(() {
      filteredBookings = bookingList.where((booking) {
        var customerDetails = booking['customerDetails'];

        // Combine first and last name into a single string
        String fullName = (customerDetails?['firstName'] ?? '') +
            ' ' +
            (customerDetails?['lastName'] ?? '');

        // Check if the combined full name matches the search query
        bool matchesName =
            fullName.toLowerCase().contains(searchQuery.toLowerCase());

        // Check if the phone number matches
        bool matchesPhone = customerDetails != null &&
            (customerDetails['phoneNumber']?.contains(searchQuery) ?? false);

        bool matchesDate = true;

        // Check date range filtering
        if (selectedStartDate != null && selectedEndDate != null) {
          DateTime startDate = DateTime.parse(booking['startDate']);
          matchesDate = startDate.isAfter(selectedStartDate!) &&
              startDate.isBefore(selectedEndDate!.add(Duration(days: 1)));
        }

        // Return true if either the name or phone matches and date conditions are met
        return (matchesName || matchesPhone) && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
        applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        title: Text(
          'Booking List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () =>
                _selectDateRange(context), // Open date range picker
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  searchQuery = value;
                  applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ),
            // Booking count display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                      "Showing ${filteredBookings.length} booking${filteredBookings.length == 1 ? "" : "s"} available",
                      style: AppTextStyles.subheadingStyleLight),
                ),
              ),
            ),
            // Display loading state
            if (isLoading)
              Card(
                color: AppColors.white,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking Details       ",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Changed to start
                        children: [
                          Text(
                            "Customer:   ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          // The text you want to display
                          SizedBox(width: 10),
                          // Space between text and loading indicator
                          Container(
                            height: 30,
                            width: 100, // Set a width to ensure visibility
                            child: CustomLoadingIndicator(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal:
                                      10), // Adjusted horizontal padding
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Changed to start
                        children: [
                          Text(
                            "Phone: ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          // The text you want to display
                          SizedBox(width: 10),
                          // Space between text and loading indicator
                          Container(
                            height: 30,
                            width: 100, // Set a width to ensure visibility
                            child: CustomLoadingIndicator(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal:
                                  10), // Adjusted horizontal padding
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Changed to start
                        children: [
                          Text(
                            "Check-in Date: ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          // The text you want to display
                          SizedBox(width: 10),
                          // Space between text and loading indicator
                          Container(
                            height: 30,
                            width: 100, // Set a width to ensure visibility
                            child: CustomLoadingIndicator(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal:
                                  10), // Adjusted horizontal padding
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Changed to start
                        children: [
                          Text(
                            "Check-out Date: ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          // The text you want to display
                          SizedBox(width: 10),
                          // Space between text and loading indicator
                          Container(
                            height: 30,
                            width: 100, // Set a width to ensure visibility
                            child: CustomLoadingIndicator(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal:
                                  10), // Adjusted horizontal padding
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // Changed to start
                        children: [
                          Text(
                            "Number of Days: ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          // The text you want to display
                          SizedBox(width: 10),
                          // Space between text and loading indicator
                          Container(
                            height: 30,
                            width: 100, // Set a width to ensure visibility
                            child: CustomLoadingIndicator(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal:
                                  10), // Adjusted horizontal padding
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),

            // List of bookings
            if (!isLoading)
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Text(
                          "No bookings available",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          var booking = filteredBookings[index];
                          var customerDetails = booking['customerDetails'];

                          // Calculate the number of days
                          DateTime startDate =
                              DateTime.parse(booking['startDate']);
                          DateTime endDate = DateTime.parse(booking[
                              'endDate']); // Assuming 'endDate' is available in the booking
                          int numberOfDays =
                              endDate.difference(startDate).inDays;

                          return Card(
                            color: AppColors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Booking Details",
                                    style: AppTextStyles.headingStyleBold.copyWith(color: AppColors.primaryGreen)
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Customer:          ${customerDetails != null ? '${customerDetails['firstName']} ${customerDetails['lastName']}' : 'N/A'}",
                                    style: AppTextStyles.subheadingStyle
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Phone:               ${customerDetails != null ? customerDetails['phoneNumber'] : 'N/A'}",
                                    style:  AppTextStyles.subheadingStyle
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Check-in Date   : ${booking['startDate'] != null ? DateTime.parse(booking['startDate']).toLocal().toString().split(' ')[0] : 'N/A'}",
                                    style:  AppTextStyles.subheadingStyle
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Check-out Date: ${booking['endDate'] != null ? DateTime.parse(booking['endDate']).toLocal().toString().split(' ')[0] : 'N/A'}",
                                    style:  AppTextStyles.subheadingStyle
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Number of Days: $numberOfDays",
                                    style:  AppTextStyles.subheadingStyle
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
