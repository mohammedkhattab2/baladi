// Presentation - Ad cubit states.
//
// Defines all possible states for the advertisement feature including
// active ads for customers and shop ad management.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/ad.dart';

/// Base state for the ad cubit.
abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object?> get props => [];
}

/// Initial state — ads not yet loaded.
class AdInitial extends AdState {
  const AdInitial();
}

/// Ads are being fetched.
class AdLoading extends AdState {
  const AdLoading();
}

/// Active ads loaded (customer view).
class ActiveAdsLoaded extends AdState {
  /// Currently active advertisements.
  final List<Ad> activeAds;

  const ActiveAdsLoaded({required this.activeAds});

  @override
  List<Object?> get props => [activeAds];
}

/// Shop's own ads loaded (shop owner view).
class ShopAdsLoaded extends AdState {
  /// The shop's advertisements.
  final List<Ad> shopAds;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const ShopAdsLoaded({
    required this.shopAds,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [shopAds, currentPage, hasMore];
}

/// An ad creation is in progress.
class AdCreating extends AdState {
  const AdCreating();
}

/// An ad was created successfully.
class AdCreated extends AdState {
  /// The newly created ad.
  final Ad ad;

  const AdCreated({required this.ad});

  @override
  List<Object?> get props => [ad];
}

/// A single ad's details loaded.
class AdDetailLoaded extends AdState {
  /// The ad details.
  final Ad ad;

  const AdDetailLoaded({required this.ad});

  @override
  List<Object?> get props => [ad];
}

/// An error occurred during an ad operation.
class AdError extends AdState {
  /// The error message to display.
  final String message;

  const AdError({required this.message});

  @override
  List<Object?> get props => [message];
}