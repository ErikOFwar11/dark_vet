import 'package:flutter/material.dart';

void main() {
  runApp(const VetCalcApp());
}

class VetCalcApp extends StatefulWidget {
  const VetCalcApp({super.key});

  @override
  State<VetCalcApp> createState() => _VetCalcAppState();
}

class _VetCalcAppState extends State<VetCalcApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cálculo de Dosis Vet',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Negro puro AMOLED
        canvasColor: Colors.black,
        cardColor: const Color(0xFF121212), // Gris ultra oscuro para tarjetas (contraste perfecto)
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          surface: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: DosageCalculatorScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class DosageCalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const DosageCalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<DosageCalculatorScreen> createState() => _DosageCalculatorScreenState();
}

class _DosageCalculatorScreenState extends State<DosageCalculatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _concentrationController = TextEditingController();

  bool _isMicrograms = false;

  double? _volumeMl;
  double? _totalDoseMg;

  @override
  void dispose() {
    _weightController.dispose();
    _doseController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  // Función auxiliar para parsear valores reemplazando comas por puntos de forma segura
  double? _parseFlexibleDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _calculateDose() {
    if (_formKey.currentState!.validate()) {
      final double weight = _parseFlexibleDouble(_weightController.text) ?? 0.0;
      final double inputDose = _parseFlexibleDouble(_doseController.text) ?? 0.0;
      final double concentration = _parseFlexibleDouble(_concentrationController.text) ?? 1.0;

      setState(() {
        if (_isMicrograms) {
          _totalDoseMg = (weight * inputDose) / 1000.0;
        } else {
          _totalDoseMg = weight * inputDose;
        }
        _volumeMl = concentration > 0 ? _totalDoseMg! / concentration : 0.0;
      });
    }
  }

  void _resetFields() {
    setState(() {
      _weightController.clear();
      _doseController.clear();
      _concentrationController.clear();
      _volumeMl = null;
      _totalDoseMg = null;
      _isMicrograms = false;
    });
  }

  String _getDoseResultText() {
    if (_totalDoseMg == null) return '';
    if (_totalDoseMg! < 1) {
      return 'Dosis total requerida: ${(_totalDoseMg! * 1000.0).toStringAsFixed(1)} mcg';
    } else {
      return 'Dosis total requerida: ${_totalDoseMg!.toStringAsFixed(2)} mg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Dosis Vet'),
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Cambiar a Modo Claro' : 'Cambiar a Modo Oscuro AMOLED',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFields,
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 110.0,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? const Color(0xFF1E2929) : const Color(0xFFC1EBEB),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/cat_banner.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Peso del paciente (kg)',
                    prefixIcon: const Icon(Icons.fitness_center),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el peso';
                    final parsed = _parseFlexibleDouble(value);
                    if (parsed == null || parsed <= 0) return 'Peso no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _doseController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _isMicrograms ? 'Dosis recomendada (mcg/kg)' : 'Dosis recomendada (mg/kg)',
                          prefixIcon: const Icon(Icons.local_hospital),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingrese la dosis';
                          final parsed = _parseFlexibleDouble(value);
                          if (parsed == null || parsed <= 0) return 'Dosis no válida';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 56.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'mg',
                              style: TextStyle(
                                fontWeight: !_isMicrograms ? FontWeight.bold : FontWeight.normal,
                                color: !_isMicrograms ? (widget.isDarkMode ? Colors.tealAccent : Colors.teal) : Colors.grey,
                              ),
                            ),
                            Switch(
                              value: _isMicrograms,
                              activeThumbColor: widget.isDarkMode ? Colors.black : Colors.teal,
                              onChanged: (value) {
                                setState(() {
                                  _isMicrograms = value;
                                });
                              },
                            ),
                            Text(
                              'mcg',
                              style: TextStyle(
                                fontWeight: _isMicrograms ? FontWeight.bold : FontWeight.normal,
                                color: _isMicrograms ? (widget.isDarkMode ? Colors.tealAccent : Colors.teal) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _concentrationController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Concentración del fármaco (mg/ml)',
                    prefixIcon: const Icon(Icons.science),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese la concentración';
                    final parsed = _parseFlexibleDouble(value);
                    if (parsed == null || parsed <= 0) return 'Concentración no válida';
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _calculateDose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                    foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('CALCULAR DOSIS', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24.0),
                if (_volumeMl != null && _totalDoseMg != null)
                  Card(
                    elevation: 4.0,
                    color: widget.isDarkMode ? const Color(0xFF1E2929) : Colors.teal.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'VOLUMEN A ADMINISTRAR',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${_volumeMl!.toStringAsFixed(3)} ml',
                            style: TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const Divider(height: 30.0),
                          Text(
                            _getDoseResultText(),
                            style: TextStyle(
                              fontSize: 16.0,
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32.0),
                // Footer con la frase y diseño profesional/humorístico
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Eres médico, no carnicero.',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 1, color: Colors.grey.shade400),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('🐾', style: TextStyle(fontSize: 14.0)),
                          ),
                          Container(width: 30, height: 1, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}