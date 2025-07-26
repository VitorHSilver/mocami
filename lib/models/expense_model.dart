class Expense {
  String description;
  double? value;
  DateTime date;

  Expense({
    required this.description, 
    this.value, 
    DateTime? date
  }) : date = date ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'description': description, 
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      value: json['value']?.toDouble(),
      date: json['date'] != null 
        ? DateTime.parse(json['date']) 
        : DateTime.now(),
    );
  }
  
  String get formattedDate {
    return '${date.day}/${date.month}';
  }
}
