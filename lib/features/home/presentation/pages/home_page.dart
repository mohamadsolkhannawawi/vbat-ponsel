import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';
import 'home_header_sliver.dart';
import 'package:vbat_ponsel/core/widgets/video_preview_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  final Color _bgLight = const Color(0xFFF1F3FF);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);

  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  Duration _flashSaleTime = const Duration(hours: 2, minutes: 48, seconds: 15);

  final List<Map<String, dynamic>> _feedItems = [];
  bool _isLoadingMore = false;

  // Template data untuk 2-kolom grid rekomendasi
  final List<Map<String, dynamic>> _productTemplates = [
    {
      "type": "product",
      "name": "Baterai Infinix Hot 10 Play BL-58BX Original",
      "price": "Rp145.000",
      "rating": "4.9",
      "sold": "1.5RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095"
    },
    {
      "type": "product",
      "name": "LCD iPhone 11 Pro Max OLED Original Quality",
      "price": "Rp1.250.000",
      "rating": "4.8",
      "sold": "850",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts?categoryId=100013&entryPoint=ShopByPDP&itemId=22913463095"
    },
    {
      "type": "product",
      "name": "Obeng Set Magnetik 24 in 1 Presisi S2 Steel",
      "price": "Rp45.000",
      "rating": "4.8",
      "sold": "3.2RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts"
    },
    {
      "type": "product",
      "name": "Flux Amtech NC-559-ASM Original 10cc",
      "price": "Rp85.000",
      "rating": "4.9",
      "sold": "4.5RB",
      "image": "assets/images/product_battery.png",
      "link": "https://shopee.co.id/brader_parts"
    },
    {
      "type": "product",
      "name": "Blower Quick 857D Hot Air Gun Digital",
      "price": "Rp850.000",
      "rating": "4.9",
      "sold": "190",
      "image": "assets/images/product_lcd.png",
      "link": "https://shopee.co.id/brader_parts"
    }
  ];

  final List<Map<String, dynamic>> _learningTemplates = [
    {
      "type": "learning",
      "title": "Mastering iPhone 13 LCD Replacement & TrueTone",
      "instructor": "Budi VBat",
      "duration": "45:00",
      "views": "12.4K",
      "image": "assets/images/course_soldering.png",
      "videoUrl": "assets/videos/sample_course.mp4",
      "badge": "PREMIUM"
    },
    {
      "type": "learning",
      "title": "Cara Jumper Jalur IC Power iPhone 11 Mati Total",
      "instructor": "Chen Fixer",
      "duration": "28:15",
      "views": "8.5K",
      "image": "assets/images/course_soldering.png",
      "badge": "FREE"
    },
    {
      "type": "learning",
      "title": "Analisa Short Circuit VBat Menggunakan Thermal Cam",
      "instructor": "Agus Solder",
      "duration": "35:40",
      "views": "20.1K",
      "image": "assets/images/course_soldering.png",
      "badge": "PREMIUM"
    },
    {
      "type": "learning",
      "title": "Bongkar Pasang Connector Charger Android Universal",
      "instructor": "Tim VBat",
      "duration": "18:20",
      "views": "5.3K",
      "image": "assets/images/course_soldering.png",
      "badge": "FREE"
    }
  ];

  final List<Map<String, dynamic>> _partnerLogoTemplates = [
    {"name": "BraderParts", "color": Colors.white, "badge": Colors.blue, "image": "assets/images/logo_braderparts.png"},
    {"name": "TITAN Tools", "color": Colors.white, "badge": Colors.blue, "image": "assets/images/logo_titan.png"},
    {"name": "BT-ACC Battery", "color": Colors.white, "badge": Colors.amber, "image": "assets/images/logo_btacc.png"},
    {"name": "Sunshine", "color": Colors.white, "badge": Colors.grey, "image": "assets/images/logo_sunshine.png"},
    {"name": "Borneo Schematics", "color": Colors.white, "badge": Colors.grey, "image": "assets/images/logo_borneo.png"},
    {"name": "Pragmafix", "color": Colors.white, "badge": Colors.grey, "image": "assets/images/logo_pragmafix.png"},
  ];

  @override
  void initState() {
    super.initState();

    // Jalankan timer untuk Flash Sale
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_flashSaleTime.inSeconds > 0) {
          _flashSaleTime = Duration(seconds: _flashSaleTime.inSeconds - 1);
        }
      });
    });

    // Inisialisasi Feed awal (Dominan produk & kursus, banner minimal)
    _feedItems.add({"type": "sliding_banner"});
    _feedItems.add(Map<String, dynamic>.from(_productTemplates[0]));
    _feedItems.add(Map<String, dynamic>.from(_learningTemplates[0]));
    _feedItems.add(Map<String, dynamic>.from(_productTemplates[1]));
    _feedItems.add(Map<String, dynamic>.from(_learningTemplates[1]));
    
    // Generate sisanya
    _generateFeedItems(count: 8);

    // Scroll listener untuk infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateFeedItems({required int count}) {
    final Random random = Random();
    for (int i = 0; i < count; i++) {
      // 80% produk/kursus, 10% banner, 10% partner
      int typeChoice = random.nextInt(10);
      if (typeChoice <= 4) {
        // 0-4: produk (50%)
        var template = _productTemplates[random.nextInt(_productTemplates.length)];
        _feedItems.add(Map<String, dynamic>.from(template));
      } else if (typeChoice <= 7) {
        // 5-7: learning (30%)
        var template = _learningTemplates[random.nextInt(_learningTemplates.length)];
        _feedItems.add(Map<String, dynamic>.from(template));
      } else if (typeChoice == 8) {
        // 8: sliding_banner (10%)
        _feedItems.add({"type": "sliding_banner"});
      } else {
        // 9: partner_card (10%)
        var partner = _partnerLogoTemplates[random.nextInt(_partnerLogoTemplates.length)];
        _feedItems.add({
          "type": "partner_card",
          "partner": partner,
        });
      }
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _generateFeedItems(count: 4);
        _isLoadingMore = false;
      });
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: _buildSlivers(context),
      ),
    );
  }

  // --- Dynamic Slivers Generator (Alternating Grid & Full Width Blocks) ---
  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = [];

    // 1. Header Sliver
    slivers.add(const HomeHeaderSliver());

    // 2. Quick Actions Container
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildQuickAction(
                  Icons.local_activity_rounded,
                  Colors.blue,
                  "Sertifikat Saya",
                  "Lihat pencapaian",
                  onTap: () => context.push('/certificate'),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                  "Streak Belajar",
                  "3 hari beruntun!",
                  onTap: () => _showStreakDialog(),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  Icons.credit_card_rounded,
                  Colors.brown,
                  "Member VBat",
                  "Diskon 10%",
                  onTap: () => _showMemberDialog(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 3. Grid Menu Ikon Utama
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconMenu(
                Icons.school_rounded,
                "Kelas Saya",
                badge: "",
                onTap: () {
                  SessionManager.currentTabIndex.value = 3;
                },
              ),
              _buildIconMenu(
                Icons.build_rounded,
                "Alat Servis",
                badge: "PROMO",
                badgeColor: Colors.red,
                onTap: () {
                  SessionManager.currentTabIndex.value = 1;
                },
              ),
              _buildIconMenu(
                Icons.stars_rounded,
                "VBat Premium",
                badge: "VIP",
                badgeColor: Colors.amber.shade700,
                onTap: () => context.push('/subscription'),
              ),
              _buildIconMenu(
                Icons.forum_rounded,
                "Forum Teknisi",
                badge: "",
                onTap: () {
                  SessionManager.currentTabIndex.value = 2;
                },
              ),
              _buildIconMenu(
                Icons.location_on_rounded,
                "Mitra",
                badge: "",
                onTap: () {
                  SessionManager.currentTabIndex.value = 1;
                },
              ),
            ],
          ),
        ),
      ),
    );

    // 4. Flash Sale Section
    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _orangeSale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "FLASH SALE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Text(
                      _formatDuration(_flashSaleTime),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      SessionManager.currentTabIndex.value = 1;
                    },
                    child: Row(
                      children: [
                        Text(
                          "Lihat Semua",
                          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Icon(Icons.chevron_right_rounded, color: _primaryBlue, size: 16),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFlashSaleCard(
                      "Infinix Hot 10 Play Battery",
                      "Rp145.000",
                      "Rp220.000",
                      "35%",
                      "assets/images/product_battery.png",
                    ),
                    const SizedBox(width: 12),
                    _buildFlashSaleCard(
                      "LCD iPhone 11 Pro Max OLED",
                      "Rp1.250.000",
                      "Rp1.850.000",
                      "32%",
                      "assets/images/product_lcd.png",
                    ),
                    const SizedBox(width: 12),
                    _buildFlashSaleCard(
                      "Obeng Set Presisi 24 in 1 Magnet",
                      "Rp45.000",
                      "Rp80.000",
                      "44%",
                      "assets/images/product_battery.png",
                    ),
                    const SizedBox(width: 12),
                    _buildFlashSaleCard(
                      "Flux Amtech NC-559-ASM 10cc",
                      "Rp85.000",
                      "Rp130.000",
                      "34%",
                      "assets/images/product_battery.png",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 5. Header Rekomendasi
    slivers.add(
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                "Rekomendasi Untukmu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_outline_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );

    // 6. Loop grouping feed items into batches of 4, inserting full width banners/strips in between
    int i = 0;
    int groupSize = 6; // Kelompok lebih besar agar banner tidak terlalu sering
    int groupIndex = 0;
    while (i < _feedItems.length) {
      int end = (i + groupSize < _feedItems.length) ? i + groupSize : _feedItems.length;
      List<Map<String, dynamic>> sublist = _feedItems.sublist(i, end);

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = sublist[index];
                if (item["type"] == "sliding_banner") {
                  return const SlidingBannerCardWidget();
                } else if (item["type"] == "partner_card") {
                  return PartnerLogoCardWidget(partner: item["partner"]);
                } else {
                  return _buildGridCard(context, item);
                }
              },
              childCount: sublist.length,
            ),
          ),
        ),
      );

      // Selipkan Banner lebar penuh hanya setiap 2 grup (lebih jarang)
      if (end < _feedItems.length && groupIndex % 2 == 1) {
        if (groupIndex % 4 == 1) {
          slivers.add(SliverToBoxAdapter(child: _buildPromoBannerWidget()));
        } else {
          slivers.add(SliverToBoxAdapter(child: _buildPartnerBannerWidget()));
        }
      }
      groupIndex++;

      i = end;
    }

    // 7. Loading indicator
    if (_isLoadingMore) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 8. Safe area padding
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    );

    return slivers;
  }

  // --- Aksi Cepat Item ---
  Widget _buildQuickAction(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Menu Utama Ikon ---
  Widget _buildIconMenu(
    IconData icon,
    String label, {
    required String badge,
    Color badgeColor = Colors.transparent,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Icon(icon, color: const Color(0xFF1B4F9B), size: 24),
                ),
                if (badge.isNotEmpty)
                  Positioned(
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Flash Sale Card ---
  Widget _buildFlashSaleCard(
    String name,
    String price,
    String originalPrice,
    String discount,
    String assetImage,
  ) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/product-detail',
          extra: {
            "name": name,
            "price": price,
            "image": assetImage,
            "rating": "4.9",
            "sold": "250+",
            "link": "https://shopee.co.id/Braderparts-Baterai-Battery-Batre-BL-58BX-for-Infinix-Hot-9-Play-Hot-10-Play-Hot-10S-Hot-11-Play-Hot-12-Play-i.57356590.22913463095?extraParams=%7B%22display_model_id%22%3A350188294975%2C%22model_selection_logic%22%3A3%7D&sp_atk=f8d0ca69-2d93-4324-b982-5cd7d983550e&xptdk=f8d0ca69-2d93-4324-b982-5cd7d983550e",
          },
        );
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        assetImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.phone_android_rounded, color: Colors.grey, size: 36),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discount,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    originalPrice,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _orangeSale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Grid Card Builder (Shopee E-commerce Style) ---
  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item) {
    final bool isProduct = item["type"] == "product";
    return GestureDetector(
      onTap: () {
        if (isProduct) {
          context.push('/product-detail', extra: item);
        } else {
          context.push('/course-detail');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Preview Area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: !isProduct && item["videoUrl"] != null
                          ? VideoPreviewWidget(
                              videoUrl: item["videoUrl"],
                              fallbackImage: item["image"],
                            )
                          : Image.asset(
                              item["image"],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  isProduct ? Icons.handyman_rounded : Icons.play_circle_fill_rounded,
                                  color: isProduct ? _primaryBlue : Colors.red,
                                  size: 36,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isProduct ? _primaryBlue : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isProduct ? "PRODUK" : "KURSUS",
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProduct ? item["name"] : item["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isProduct)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                        Text(
                          " ${item['rating']} • ${item['sold']} terjual",
                          style: TextStyle(fontSize: 10, color: _textGray),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, color: Colors.grey, size: 12),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item["instructor"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: _textGray),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    isProduct ? item["price"] : (item["badge"] ?? "GRATIS"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isProduct ? _orangeSale : _primaryBlue,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Promo Banner ---
  Widget _buildPromoBannerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner_promo_diskon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_orangeSale, Colors.deepOrange]),
            ),
            child: const Center(
              child: Text(
                "SPECIAL PROMO - DISKON 30%",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Partner Banner ---
  Widget _buildPartnerBannerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner_braderparts.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryBlue, Colors.blue.shade900]),
            ),
            child: const Center(
              child: Text(
                "BRADERPARTS OFFICIAL PARTNER",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.local_fire_department_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Streak Belajar"),
          ],
        ),
        content: const Text("Hebat! Anda telah belajar 3 hari berturut-turut. Pertahankan streak Anda untuk mendapatkan bonus poin!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Mantap")),
        ],
      ),
    );
  }

  void _showMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.credit_card_rounded, color: Colors.brown),
            SizedBox(width: 8),
            Text("Member VBat"),
          ],
        ),
        content: const Text("Sebagai Member VBat, Anda berhak mendapatkan diskon 10% untuk semua pembelian suku cadang di BraderParts resmi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }


}

// --- Sliding Banner Card Widget (Auto Sliding Carousel) ---
class SlidingBannerCardWidget extends StatefulWidget {
  const SlidingBannerCardWidget({super.key});

  @override
  State<SlidingBannerCardWidget> createState() => _SlidingBannerCardWidgetState();
}

class _SlidingBannerCardWidgetState extends State<SlidingBannerCardWidget> {
  late final PageController _pageController;
  Timer? _sliderTimer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      "title": "Diskon Alat & Suku Cadang",
      "desc": "Hemat s.d 30% khusus hari ini",
      "color1": const Color(0xFFFD761A),
      "color2": const Color(0xFFFF9800),
      "image": "assets/images/banner_promo_diskon.png",
      "badge": "PROMO KILAT",
    },
    {
      "title": "Mitra Resmi BraderParts",
      "desc": "Modul eksklusif & parts original",
      "color1": const Color(0xFF1B4F9B),
      "color2": const Color(0xFF3B7ED9),
      "image": "assets/images/banner_braderparts.png",
      "badge": "OFFICIAL PARTNER",
    },
    {
      "title": "Gratis Ongkir Spesial",
      "desc": "Min. belanja 50rb se-Indonesia",
      "color1": const Color(0xFF03AC0E),
      "color2": const Color(0xFF2ECC71),
      "image": null,
      "badge": "FREE SHIPPING",
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _promoBanners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _promoBanners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final promo = _promoBanners[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (promo["image"] != null)
                      Image.asset(
                        promo["image"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [promo["color1"]!, promo["color2"]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [promo["color1"]!, promo["color2"]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    // Semi-transparent gradient overlay for better text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              promo["badge"]!,
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promo["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo["desc"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _promoBanners.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == index ? 12 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: _currentPage == index ? 0.9 : 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Partner Logo Card Widget (1-cell Grid Card) ---
class PartnerLogoCardWidget extends StatelessWidget {
  final Map<String, dynamic> partner;
  const PartnerLogoCardWidget({super.key, required this.partner});

  void _showPartnerDetailDialog(BuildContext context, String partnerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                partnerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001944),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mitra Distribusi Resmi & Terverifikasi VBat Ponsel.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF001944),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Menyediakan suku cadang smartphone asli bergaransi, tools perbaikan presisi, serta dukungan pasokan reguler untuk seluruh alumni dan teknisi VBat.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Jaminan 100% Produk Original",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SessionManager.currentTabIndex.value = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4F9B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Lihat Produk"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPartnerDetailDialog(context, partner["name"]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: partner["color"] ?? Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: partner["image"] != null 
                    ? ClipOval(child: Image.asset(partner["image"], fit: BoxFit.cover))
                    : Icon(
                        partner["icon"] ?? Icons.star,
                        color: partner["color"] == Colors.white ? const Color(0xFF1B4F9B) : Colors.white,
                        size: 26,
                      ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: partner["badge"] ?? Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              partner["name"],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001944),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Mitra Terverifikasi",
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4F9B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Lihat Detail",
                style: TextStyle(
                  color: Color(0xFF1B4F9B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
