import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? icon; // Optional icon name from Icons
  final int? colorCode; // Optional color hex code

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.colorCode,
  });

  @override
  List<Object?> get props => [id, name, icon, colorCode];
}
