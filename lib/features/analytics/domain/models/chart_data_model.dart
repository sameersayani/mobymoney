import 'package:flutter/material.dart';
import 'package:mobymoney/core/theme/category_color_helper.dart';
import 'package:mobymoney/features/analytics/presentation/widgets/pie_chart_widget.dart';

class ChartDataModel {
  final Map<String, dynamic> rawData;
  final List<CategorySpendingData> categories;
  final int totalAmountMinor;

  const ChartDataModel({
    required this.rawData,
    required this.categories,
    required this.totalAmountMinor,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : <String, dynamic>{});

    final Map<String, int> categoryTotals = {};

    void processCategoryMap(Map<dynamic, dynamic> catMap) {
      catMap.forEach((categoryKey, catValue) {
        final categoryName = categoryKey.toString().trim();
        if (categoryName.isEmpty) return;

        int amountMinor = 0;
        if (catValue is List) {
          for (final item in catValue) {
            if (item is Map) {
              final val = item['amount'];
              if (val is num) {
                amountMinor += (val * 100).round();
              } else if (val is String) {
                final parsed = double.tryParse(val) ?? 0.0;
                amountMinor += (parsed * 100).round();
              }
            } else if (item is num) {
              amountMinor += (item * 100).round();
            }
          }
        } else if (catValue is num) {
          amountMinor = (catValue * 100).round();
        } else if (catValue is String) {
          final parsed = double.tryParse(catValue) ?? 0.0;
          amountMinor = (parsed * 100).round();
        } else if (catValue is Map) {
          if (catValue['amount'] != null) {
            final val = catValue['amount'];
            final parsed = val is num ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
            amountMinor = (parsed * 100).round();
          } else {
            // Further nested map
            processCategoryMap(catValue);
            return;
          }
        }

        if (amountMinor > 0) {
          categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + amountMinor;
        }
      });
    }

    // Check if rawData has nested month maps or direct category maps
    rawData.forEach((key, value) {
      if (value is Map) {
        // e.g. "September 2026": { "Internet": [...], "Lab Tests": [...] }
        processCategoryMap(value);
      } else if (value is List || value is num || value is String) {
        // e.g. "Internet": 6.0 or "Internet": [...]
        processCategoryMap({key: value});
      }
    });

    final List<CategorySpendingData> catList = [];
    int totalMinor = 0;
    final Set<int> usedColors = {};
    int fallbackIndex = 0;

    categoryTotals.forEach((catName, catAmountMinor) {
      totalMinor += catAmountMinor;

      Color color = CategoryColorHelper.getColorForCategory(catName);
      if (usedColors.contains(color.toARGB32())) {
        for (int i = 0; i < CategoryColorHelper.palette.length; i++) {
          final candidate = CategoryColorHelper.palette[(fallbackIndex + i) % CategoryColorHelper.palette.length];
          if (!usedColors.contains(candidate.toARGB32())) {
            color = candidate;
            fallbackIndex = (fallbackIndex + i + 1) % CategoryColorHelper.palette.length;
            break;
          }
        }
      }
      usedColors.add(color.toARGB32());

      catList.add(
        CategorySpendingData(
          categoryName: catName,
          amountMinor: catAmountMinor,
          color: color,
        ),
      );
    });

    return ChartDataModel(
      rawData: rawData,
      categories: catList,
      totalAmountMinor: totalMinor,
    );
  }

  factory ChartDataModel.empty() {
    return const ChartDataModel(
      rawData: {},
      categories: [],
      totalAmountMinor: 0,
    );
  }
}
