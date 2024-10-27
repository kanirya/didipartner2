import 'package:didipartner/view/screens/Home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../res/components/LinearProgramindicator.dart';
import '../../../utils/constant/contants.dart';
import '../../../view_model/provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isScrolledDown = false;

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Hi, ${ap.ownerModel.name}',
                    style: AppTextStyles.bodyTextStyle),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Welcome back!', style: AppTextStyles.headingStyle),
              ),
            ],
          ),
          actions: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(ap.ownerModel.imageUrl),
            ),
            const SizedBox(width: 9),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels > 50 && !_isScrolledDown) {
            setState(() {
              _isScrolledDown = true;
            });
          } else if (scrollInfo.metrics.pixels <= 50 && _isScrolledDown) {
            setState(() {
              _isScrolledDown = false;
            });
          }
          return true;
        },
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 5, // Adjust this based on actual content
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildMainCard();
              } else if (index == 1) {
                return _buildSectionTitle('Earnings', true);
              } else if (index == 2) {
                return _buildSecondaryCard();
              } else if (index == 3) {
                return _buildSectionTitle('To-dos', false);
              } else {
                return _buildTodoCard();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(width: 1, color: Colors.black12))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Bookings",
                        style: AppTextStyles.subheadingbold,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              "4 ",
                              style: AppTextStyles.subheadingbold,
                            ),
                            Text(
                              "/ 10",
                              style: AppTextStyles.subheadingStyleLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Booking",
                        style: AppTextStyles.subheadingbold,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              "2 ",
                              style: AppTextStyles.subheadingbold,
                            ),
                            Text(
                              "/ 10",
                              style: AppTextStyles.subheadingStyleLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Booking",
                        style: AppTextStyles.subheadingbold,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              "2 ",
                              style: AppTextStyles.subheadingbold,
                            ),
                            Text(
                              "/ 12",
                              style: AppTextStyles.subheadingStyleLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                      const Divider(),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headingStyle),
          TextButton(
            onPressed: () {},
            child: details
                ? Text(
                    "Details",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget _buildTodoCard() {
    return Container(
      height: 70,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:CustomLoadingIndicator(padding: EdgeInsets.symmetric(vertical: 30,horizontal: 40),),
    );
  }
}
