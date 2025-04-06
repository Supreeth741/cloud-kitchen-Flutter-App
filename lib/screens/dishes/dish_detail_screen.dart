import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_service.dart';
import '../../models/dish.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DishDetailScreen extends StatefulWidget {
  @override
  _DishDetailScreenState createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  late Future<Dish> _dishFuture;
  final ApiService _apiService = ApiService();

  PageController _pageController = PageController();
  int _currentPage = 0;
  Future<void>? launched;

  Future<void> requestPhonePermission() async {
    // Check current permission status
    final status = await Permission.phone.status;

    if (status.isDenied) {
      // Request permission
      if (await Permission.phone.request().isGranted) {
        // ignore: avoid_print
        print('Phone permission granted.');
      } else {
        // ignore: avoid_print
        print('Phone permission denied.');
      }
    } else if (status.isGranted) {
      // ignore: avoid_print
      print('Phone permission already granted.');
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied permissions
      // ignore: avoid_print
      print(
        'Phone permission permanently denied. Please enable it in settings.',
      );
      openAppSettings();
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dishId = ModalRoute.of(context)!.settings.arguments as int;
    _dishFuture = _apiService.getDishDetails(dishId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dish Details')),
      body: FutureBuilder<Dish>(
        future: _dishFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading dish details'));
          }
          final dish = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: dish.imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) => Container(
                          width: MediaQuery.of(context).size.width,
                          child: CachedNetworkImage(
                            imageUrl: dish.imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(dish.imageUrls.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 12 : 8,
                              height: _currentPage == index ? 12 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  dish.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 10),
                Text(
                  'Category: ${dish.category.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 19, 19, 19)),
                ),
                SizedBox(height: 20),
                Text(
                  dish.description ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    requestPhonePermission();
                    setState(() {
                      launched = makePhoneCall('+917019356439');
                    });
                  },
                  child: Text(
                    'Contact: ${dish.contactNumber}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
