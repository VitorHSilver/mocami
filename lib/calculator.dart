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

  const Calculator({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);
  
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
        _textController.text = savedInput;
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
                    color: widget.isDarkMode ? Colors.white : AppColors.darkAppBar,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                ],
              ),
                IconButton(
                  icon: Icon(Icons.delete,
                  color: widget.isDarkMode ? Colors.white : AppColors.darkAppBar,
                  ),
                  tooltip: 'Limpar lista de dados',
                  onPressed: () async {
                    setState(() {
                      input = '';
                      expenses = [];
                      _textController.clear();
                    });
                    await StorageService.clearAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dados limpos!')),
                    );
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
                );
              },
              ),
            ),
            ListTile(
              title: Text(
              'Total',
               style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.bold , 
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
                borderSide: BorderSide(color: Color.fromARGB(255, 25, 123, 189), width: 2),
              ),
              hintText: 'Digite suas despesas (ex: Viagem 500)',
              suffixIcon: _isSaving
                ? Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : null,
              ),
              onChanged: (value) {
              _onInputChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
