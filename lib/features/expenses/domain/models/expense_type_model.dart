import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExpenseTypeModel {
  final int id;
  final String name;

  const ExpenseTypeModel({
    required this.id,
    required this.name,
  });

  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTypeModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Expense',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Returns an appropriate PhosphorIcon based on the expense type name
  IconData get icon {
    final lower = name.toLowerCase().trim();
    if (lower.contains('bill') || lower.contains('receipt')) {
      return PhosphorIconsRegular.receipt;
    } else if (lower.contains('book')) {
      return PhosphorIconsRegular.bookOpen;
    } else if (lower.contains('cinema') || lower.contains('movie')) {
      return PhosphorIconsRegular.filmSlate;
    } else if (lower.contains('cloth') || lower.contains('wear')) {
      return PhosphorIconsRegular.tShirt;
    } else if (lower.contains('doctor') || lower.contains('hospital') || lower.contains('clinic')) {
      return PhosphorIconsRegular.firstAid;
    } else if (lower.contains('eat') || lower.contains('party') || lower.contains('food') || lower.contains('dining') || lower.contains('restaurant')) {
      return PhosphorIconsRegular.forkKnife;
    } else if (lower.contains('game') || lower.contains('entertainment')) {
      return PhosphorIconsRegular.gameController;
    } else if (lower.contains('grocer') || lower.contains('supermarket')) {
      return PhosphorIconsRegular.shoppingCart;
    } else if (lower.contains('internet') || lower.contains('wifi') || lower.contains('broadband')) {
      return PhosphorIconsRegular.wifiHigh;
    } else if (lower.contains('lab') || lower.contains('test')) {
      return PhosphorIconsRegular.flask;
    } else if (lower.contains('lpg') || lower.contains('gas')) {
      return PhosphorIconsRegular.fire;
    } else if (lower.contains('medicin') || lower.contains('pharma') || lower.contains('pill')) {
      return PhosphorIconsRegular.pill;
    } else if (lower.contains('mobile') || lower.contains('phone')) {
      return PhosphorIconsRegular.deviceMobile;
    } else if (lower.contains('parking')) {
      return PhosphorIconsRegular.car;
    } else if (lower.contains('petrol') || lower.contains('fuel') || lower.contains('diesel')) {
      return PhosphorIconsRegular.gasPump;
    } else if (lower.contains('recharge')) {
      return PhosphorIconsRegular.lightning;
    } else if (lower.contains('repair') || lower.contains('service') || lower.contains('maintain')) {
      return PhosphorIconsRegular.wrench;
    } else if (lower.contains('saloon') || lower.contains('salon') || lower.contains('hair') || lower.contains('spa')) {
      return PhosphorIconsRegular.scissors;
    } else if (lower.contains('school') || lower.contains('college') || lower.contains('tuition') || lower.contains('education') || lower.contains('fee')) {
      return PhosphorIconsRegular.graduationCap;
    } else if (lower.contains('shop')) {
      return PhosphorIconsRegular.shoppingBag;
    } else if (lower.contains('subscri')) {
      return PhosphorIconsRegular.television;
    } else if (lower.contains('travel') || lower.contains('trip') || lower.contains('flight') || lower.contains('hotel')) {
      return PhosphorIconsRegular.airplane;
    } else if (lower.contains('unplanned') || lower.contains('emergency')) {
      return PhosphorIconsRegular.warningCircle;
    } else if (lower.contains('watch')) {
      return PhosphorIconsRegular.watch;
    }
    return PhosphorIconsRegular.tag;
  }

  /// Returns a curated color for the category tag / avatar
  Color get color {
    final lower = name.toLowerCase().trim();
    if (lower.contains('bill')) {
      return const Color(0xFF0284C7); // Sky blue
    } else if (lower.contains('book')) {
      return const Color(0xFF8B5CF6); // Violet
    } else if (lower.contains('cinema') || lower.contains('entertainment') || lower.contains('game')) {
      return const Color(0xFFEC4899); // Pink
    } else if (lower.contains('cloth') || lower.contains('shop')) {
      return const Color(0xFF7C3AED); // Deep Purple
    } else if (lower.contains('doctor') || lower.contains('lab') || lower.contains('medicin')) {
      return const Color(0xFFEF4444); // Crimson
    } else if (lower.contains('eat') || lower.contains('party') || lower.contains('food')) {
      return const Color(0xFFF59E0B); // Amber
    } else if (lower.contains('grocer')) {
      return const Color(0xFF10B981); // Emerald
    } else if (lower.contains('internet') || lower.contains('recharge') || lower.contains('mobile')) {
      return const Color(0xFF06B6D4); // Cyan
    } else if (lower.contains('lpg') || lower.contains('petrol') || lower.contains('fuel')) {
      return const Color(0xFFEA580C); // Deep Orange
    } else if (lower.contains('repair') || lower.contains('service')) {
      return const Color(0xFF64748B); // Slate
    } else if (lower.contains('saloon') || lower.contains('watch')) {
      return const Color(0xFFD946EF); // Fuchsia
    } else if (lower.contains('school') || lower.contains('college') || lower.contains('tuition')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lower.contains('subscri')) {
      return const Color(0xFFE11D48); // Rose
    } else if (lower.contains('travel')) {
      return const Color(0xFF0F766E); // Teal
    } else if (lower.contains('unplanned')) {
      return const Color(0xFFDC2626); // Red
    }
    return const Color(0xFF0F766E); // Default primary teal
  }
}
