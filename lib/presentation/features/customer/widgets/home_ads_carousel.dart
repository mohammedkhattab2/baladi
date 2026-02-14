import 'dart:async';

import 'package:baladi/presentation/cubits/ad/ad_cubit.dart';
import 'package:baladi/presentation/cubits/ad/ad_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAdsCarousel extends StatefulWidget {
  const HomeAdsCarousel({super.key});

  @override
  State<HomeAdsCarousel> createState() => _HomeAdsCarouselState();
}

class _HomeAdsCarouselState extends State<HomeAdsCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int totalPages) {
    _autoScrollTimer?.cancel();
    if (totalPages <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % totalPages;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdCubit, AdState>(
      listener: (context, state){
        if (state is ActiveAdsLoaded && state.ads)
      },
      builder: builder, 
      
      );
  }
}