// Presentation - Ad cubit.
//
// Manages advertisement state including fetching active ads
// for customers, shop ad management, and ad creation.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/ad_repository.dart';
import 'ad_state.dart';

/// Cubit that manages all advertisement-related operations.
///
/// Handles loading active ads for the customer home screen,
/// loading shop-owned ads, creating new ads, and fetching
/// individual ad details.
@injectable
class AdCubit extends Cubit<AdState> {
  final AdRepository _adRepository;

  /// Creates an [AdCubit].
  AdCubit({
    required AdRepository adRepository,
  })  : _adRepository = adRepository,
        super(const AdInitial());

  // ---------------------------------------------------------------------------
  // Active Ads (Customer View)
  // ---------------------------------------------------------------------------

  /// Loads currently active advertisements for the customer home screen.
  Future<void> loadActiveAds() async {
    emit(const AdLoading());

    final result = await _adRepository.getActiveAds();

    result.fold(
      onSuccess: (ads) {
        emit(ActiveAdsLoaded(activeAds: ads));
      },
      onFailure: (failure) {
        emit(AdError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shop Ads (Shop Owner View)
  // ---------------------------------------------------------------------------

  /// Loads the current shop's advertisements.
  Future<void> loadShopAds({int perPage = AppConstants.defaultPageSize}) async {
    emit(const AdLoading());

    final result = await _adRepository.getShopAds(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (ads) {
        emit(ShopAdsLoaded(
          shopAds: ads,
          currentPage: 1,
          hasMore: ads.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdError(message: failure.message));
      },
    );
  }

  /// Loads more shop ads (next page).
  Future<void> loadMoreShopAds({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! ShopAdsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adRepository.getShopAds(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newAds) {
        emit(ShopAdsLoaded(
          shopAds: [...currentState.shopAds, ...newAds],
          currentPage: nextPage,
          hasMore: newAds.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Create Ad
  // ---------------------------------------------------------------------------

  /// Creates a new advertisement for the shop.
  ///
  /// - [title]: Ad title in English.
  /// - [titleAr]: Ad title in Arabic (optional).
  /// - [description]: Ad description (optional).
  /// - [imageUrl]: Ad image URL (optional).
  /// - [startDate]: When the ad should start showing.
  /// - [endDate]: When the ad should stop showing.
  Future<void> createAd({
    required String title,
    String? titleAr,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(const AdCreating());

    final result = await _adRepository.createAd(
      title: title,
      titleAr: titleAr,
      description: description,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      onSuccess: (ad) {
        emit(AdCreated(ad: ad));
      },
      onFailure: (failure) {
        emit(AdError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Ad Detail
  // ---------------------------------------------------------------------------

  /// Loads a single ad's details by ID.
  Future<void> loadAdDetail(String adId) async {
    emit(const AdLoading());

    final result = await _adRepository.getAdById(adId);

    result.fold(
      onSuccess: (ad) {
        emit(AdDetailLoaded(ad: ad));
      },
      onFailure: (failure) {
        emit(AdError(message: failure.message));
      },
    );
  }
}