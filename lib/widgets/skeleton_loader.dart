import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;

/// Skeleton loader widget with shimmer effects
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Service selection skeleton loader
class ServiceSelectionSkeleton extends StatelessWidget {
  const ServiceSelectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title skeleton
        const SkeletonLoader(width: 120, height: 16),
        const SizedBox(height: 8),
        // Service picker skeleton
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonLoader(width: 150, height: 16),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Spare parts grid skeleton loader
class SparePartsGridSkeleton extends StatelessWidget {
  final int itemCount;

  const SparePartsGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SparePartCardSkeleton();
      },
    );
  }
}

/// Individual spare part card skeleton
class SparePartCardSkeleton extends StatelessWidget {
  const SparePartCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const SkeletonLoader(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                // Price
                const SkeletonLoader(width: 80, height: 14),
                const SizedBox(height: 12),
                // Button
                const SkeletonLoader(width: double.infinity, height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Form field skeleton loader
class FormFieldSkeleton extends StatelessWidget {
  const FormFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const SkeletonLoader(width: 100, height: 16),
        const SizedBox(height: 8),
        // Input field
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLoader(width: double.infinity, height: 16),
          ),
        ),
      ],
    );
  }
}

/// Loading overlay for existing content
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
      ],
    );
  }
}

/// Shimmer list for vertical scrolling content
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 60,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const SkeletonLoader(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    const SkeletonLoader(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Service list skeleton loader (for mechanics and bookings pages)
class ServiceListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ServiceListSkeletonLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service name
              const SkeletonLoader(width: 200, height: 20),
              const SizedBox(height: 8),
              // Service description
              const SkeletonLoader(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              const SkeletonLoader(width: 150, height: 14),
              const SizedBox(height: 12),
              // Price and button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoader(width: 80, height: 16),
                  const SkeletonLoader(width: 100, height: 36),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Spare parts list skeleton loader
class SparePartsListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;

  const SparePartsListSkeletonLoader({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.mainAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SparePartCardSkeleton();
      },
    );
  }
}