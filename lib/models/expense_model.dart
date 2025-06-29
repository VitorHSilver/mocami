class Expense {
  String description;
  double? value;

  Expense({required this.description, this.value});
  
  Map<String, dynamic> toJson() {
    return {'description': description, 'value': value};
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      value: json['value']?.toDouble(),
    );
  }
}
