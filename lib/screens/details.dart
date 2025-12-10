import 'package:flutter/material.dart';
import 'package:home_finder/widgets/app_bottom_nav.dart';
import '../utils/colors.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _page = 0;
  bool _expanded = false;

  final List<String> images = [
    'assets/images/maison.jpeg',
    'assets/images/maison2.jpeg',
    'assets/images/maison3.jpeg',
    'assets/images/maison4.jpeg',
    'assets/images/maison5.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, index) {
                          return Image.asset(images[index], fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  width: _page == i ? 12 : 8,
                  height: _page == i ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primaryDark
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maison familiale moderne',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Agoè Assiyéyé, TG',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      const Text('4,5', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _amenityIcon(Icons.wifi),
                      const SizedBox(width: 10),
                      _amenityIcon(Icons.local_parking),
                      const SizedBox(width: 10),
                      _amenityIcon(Icons.bathtub),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Descriptions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDescription(),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: AssetImage(
                              'assets/images/profile.jpeg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'TOTO Patrick',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'propriétaire',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text('5.0', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.more_horiz),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(56, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {},
                    child: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('Commandez Maintenant'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.chat_bubble_outline),
        onPressed: () {},
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildDescription() {
    const text =
        'Maison familiale moderne, spacieuse et lumineuse, offrant un confort optimal avec des espaces de vie ouverts, un jardin aménagé et des finitions contemporaines. Idéale pour accueillir toute ...';
    final short = text.length > 130 ? '${text.substring(0, 130)}...' : text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _expanded ? text : short,
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Lire moins' : 'Lire plus',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _amenityIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _bottomItem(IconData icon, String label, {required bool selected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? AppColors.primaryDark : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryDark : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
