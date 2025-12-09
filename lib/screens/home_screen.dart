import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            //Header
            Padding(padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Trouver votre endroit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    ),
                    Text("idéal pour séjourner",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    ),
                  ]
                ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDark,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/user.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),

                )
              ]
            )
            ),
            //Search bar
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Recherche',
                          hintStyle: TextStyle(color: AppColors.textGray),
                          prefixIcon: Icon(Icons.search, color: AppColors.textGray,),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            //Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category chips row
                  Row(
                    children: [
                      _buildCategoryChip(' Maison', isSelected: true),
                      const SizedBox(width: 8),
                      _buildCategoryChip(' Hotel', isSelected: false),
                      const SizedBox(width: 8),
                      _buildCategoryChip(' Appartement', isSelected: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            //Proximity section
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Proximité',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                ),
              ),
            const SizedBox(height: 16),
            //Property cards List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPropertyCard(
                    imageUrl: 'assets/images/house3.jpg',
                    title: 'Maison familiale moderne',
                    location: 'Agoè Assiyéyé, TG',
                    rating: 4.5,
                    price: '500 000 000 Fcfa',
                    tag: 'Aperçu',
                  ),
                  const SizedBox(height: 16),
                  _buildPropertyCard(
                    imageUrl: 'assets/images/house2.jpg',
                    title: 'Villa moderne avec piscine',
                    location: 'Lomé, TG',
                    rating: 4.8,
                    price: '750 000 000 Fcfa',
                    tag: null,
                  ),
                  const SizedBox(height: 16),
                  _buildPropertyCard(
                    imageUrl: 'assets/images/house1.jpg',
                    title: 'Appartement de style japon',
                    location: 'Bè, TG',
                    rating: 4.2,
                    price: '300 000 000 Fcfa',
                    tag: null,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      //Navigation
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
  Widget _buildCategoryChip(String label, {required bool isSelected}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.textGray, width: 1,),
      ),
      child: Text(label,
      style: TextStyle(
        color: isSelected ? AppColors.textWhite : AppColors.textDark,
        fontWeight: FontWeight.w500,
      )),
    );
  }
  Widget _buildPropertyCard({
    required String imageUrl,
    required String title,
    required String location,
    required double rating,
    required String price,
    String? tag,
  }){
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property image with overlays
              Stack(
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Tag overlay (if exists)
                  if(tag != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                size: 16,
                                color: AppColors.textWhite,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                      ),
                    ),

                  // Favorite button
                  Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.textGray,
                          size: 20,
                        ),
                      )
                  )
                ],
              ),

              // Property details (your existing code is correct)
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Price: ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: AppColors.textGray,),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star, size: 16, color: AppColors.accent,),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.wifi, 'WiFi'),
                            _buildActionButton(Icons.local_parking, 'Parking'),
                            _buildActionButton(Icons.bed, 'Chambres'),
                          ],
                        )
                      ]
                  )
              )
            ]
        )
    );
  }
  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}