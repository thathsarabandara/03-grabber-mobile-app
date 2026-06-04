import 'package:flutter/material.dart';
import '../../../widgets/premium_widgets.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _tabController = TabController(length: 2, vsync: this);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 350,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Media Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      child: Column(
                        children: [
                          SlideFade(
                            animation: _animController,
                            delay: 0.1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 16),
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2F6),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  dividerColor: Colors.transparent,
                                  labelColor: const Color(0xFF155EEF),
                                  unselectedLabelColor: const Color(0xFF64748B),
                                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  tabs: const [
                                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.photo_rounded, size: 20), SizedBox(width: 8), Text('Photos')])),
                                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.videocam_rounded, size: 20), SizedBox(width: 8), Text('Videos')])),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildMediaGrid(context, isVideo: false),
                                _buildMediaGrid(context, isVideo: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, {required bool isVideo}) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 60),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return SlideFade(
          animation: _animController,
          delay: 0.2 + (index * 0.05),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFEFF4FF),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isVideo ? Icons.videocam_rounded : Icons.photo_rounded,
                          size: 48,
                          color: const Color(0xFF155EEF).withValues(alpha: 0.2),
                        ),
                        if (isVideo)
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D2939).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('0:15', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grabber Alpha',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D2939)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today, 10:4${index} AM',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
