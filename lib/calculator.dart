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

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    return '${now.day}/${now.month}';
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
                  style: TextStyle(color: Colors.black),
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
                  style: TextStyle(color: Colors.black),
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
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 204, 7, 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  expenses.removeAt(index);
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
              child: Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
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
                  double? valor;
                  try {
                    final parsed = CalculationService.parseExpenses(
                      'x ${valueController.text}',
                    );
                    valor = parsed.isNotEmpty ? parsed.first.value : null;
                  } catch (_) {
                    valor = double.tryParse(
                      valueController.text.replaceAll(',', '.'),
                    );
                  }
                  expenses[index] = Expense(
                    description: descController.text,
                    value: valor,
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
          'MOCAMI',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 32,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  widget.isDarkMode ? Icons.brightness_2 : Icons.wb_sunny,
                  color: widget.isDarkMode
                      ? Colors.white
                      : AppColors.darkAppBar,
                  size: 20,
                ),
                SizedBox(width: 4),
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
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: widget.isDarkMode
                        ? Colors.white
                        : AppColors.darkAppBar,
                  ),
                  tooltip: 'Limpar dados salvos',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isDarkMode
                ? [AppColors.darkAppBar, AppColors.darkBackground]
                : [AppColors.lightAppBar, AppColors.lightBackground],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${getCurrentDate()} - ',
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? const Color.fromARGB(255, 146, 146, 146)
                                    : const Color.fromARGB(218, 170, 170, 170),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: expenses[index].description,
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                style: const TextStyle(color: Colors.black),
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
                          color: Colors.black,
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
      ),
    );
  }
}
