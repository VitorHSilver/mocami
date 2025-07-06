import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'models/expense_model.dart';
import 'services/calculation_service.dart';
import 'services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'footer.dart';
import 'app_colors.dart';

class Calculator extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const Calculator({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = '';
  List<Expense> expenses = [];
  Timer? _debounceTimer;
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _onInputChanged(String value) {
    input = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        expenses = CalculationService.parseExpenses(input);
      });
      _saveData();
    });
  }

  void _handleSubmit() {
    final value = _textController.text.trim();
    if (value.isEmpty) return;
    final newExpenses = CalculationService.parseExpenses(value);
    setState(() {
      expenses.addAll(newExpenses);
      _textController.clear();
    });
    input = expenses
        .map((e) => '${e.description} ${e.value?.toStringAsFixed(2) ?? ''}')
        .join('\n');
    _saveData();
  }

  void _saveData() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await StorageService.saveLastInput(input);
      await StorageService.saveExpenses(expenses);
    } catch (e) {
      print('Erro ao salvar dados: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _editExpenseDialog(int index) {
    final expense = expenses[index];
    final descController = TextEditingController(text: expense.description);
    final valueController = TextEditingController(
      text: expense.value?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Editar despesa',
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDarkMode
                    ? AppColors.darkAppBar
                    : AppColors.lightAppBar,
                foregroundColor: widget.isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  expenses[index] = Expense(
                    description: descController.text,
                    value: double.tryParse(
                      valueController.text.replaceAll(',', '.'),
                    ),
                  );
                  input = expenses
                      .map(
                        (e) =>
                            '${e.description} ${e.value?.toStringAsFixed(2) ?? ''}',
                      )
                      .join('\n');
                  _saveData();
                });
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  double get total => CalculationService.calculateTotal(expenses);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final savedInput = await StorageService.loadLastInput();
      final savedExpenses = await StorageService.loadExpenses();

      setState(() {
        input = savedInput;
        expenses = savedExpenses;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mocami - Seu gerenciador de despesas',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 32,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Switch(
                  value: widget.isDarkMode,
                  onChanged: (value) {
                    widget.toggleTheme();
                  },
                  activeColor: const Color.fromARGB(255, 255, 255, 255),
                  activeTrackColor: Colors.grey[800],
                  inactiveThumbColor: AppColors.darkAppBar,
                  inactiveTrackColor: Colors.grey[300],
                ),
                Row(
                  children: [
                    Icon(
                      widget.isDarkMode ? Icons.brightness_2 : Icons.wb_sunny,
                      color: widget.isDarkMode
                          ? Colors.white
                          : AppColors.darkAppBar,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: widget.isDarkMode
                        ? Colors.white
                        : AppColors.darkAppBar,
                  ),
                  tooltip: 'Limpar lista de dados',
                  onPressed: () async {
                    setState(() {
                      input = '';
                      expenses = [];
                      _textController.clear();
                    });
                    await StorageService.clearAll();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Dados limpos!')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      expenses[index].description,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: widget.isDarkMode
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    trailing: Text(
                      expenses[index].value != null
                          ? expenses[index].value!.toStringAsFixed(2)
                          : '---',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    onTap: () => _editExpenseDialog(index),
                  );
                },
              ),
            ),
            ListTile(
              title: Text(
                'Total',
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: widget.isDarkMode
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              trailing: Text(
                total.toStringAsFixed(2),
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: widget.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: total.toStringAsFixed(2)),
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Total copiado!')));
              },
            ),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 25, 123, 189),
                    width: 2,
                  ),
                ),
                hintText: 'Digite suas despesas (ex: Viagem 500)',
                suffixIcon: _isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_upward_sharp),
                        tooltip: 'Adicionar despesas',
                        onPressed: _handleSubmit,
                        splashRadius: 20,
                        color: widget.isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                suffixIconConstraints: const BoxConstraints(
                  minHeight: 0,
                  minWidth: 0,
                  maxHeight: 36,
                ),
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
            Footer(
            backgroundColor: widget.isDarkMode
                ? AppColors.darkAppBar
                : AppColors.lightAppBar,
            textColor: widget.isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          ],
        ),
      ),
    );
  }
}
