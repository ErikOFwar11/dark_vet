import 'package:flutter/material.dart';

void main() {
  runApp(const VetCalcApp());
}

class VetCalcApp extends StatelessWidget {
  const VetCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cálculo de Dosis Vet',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const DosageCalculatorScreen(),
    );
  }
}

class DosageCalculatorScreen extends StatefulWidget {
  const DosageCalculatorScreen({super.key});

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

  void _calculateDose() {
    if (_formKey.currentState!.validate()) {
      final double weight = double.parse(_weightController.text);
      final double inputDose = double.parse(_doseController.text);
      final double concentration = double.parse(_concentrationController.text);

      setState(() {
        if (_isMicrograms) {
          _totalDoseMg = (weight * inputDose) / 1000.0;
        } else {
          _totalDoseMg = weight * inputDose;
        }
        _volumeMl = _totalDoseMg! / concentration;
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
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
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
                    color: const Color(0xFFC1EBEB),
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
                    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Peso no válido';
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
                          if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Dosis no válida';
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
                                color: !_isMicrograms ? Colors.teal : Colors.grey,
                              ),
                            ),
                            Switch(
                              value: _isMicrograms,
                              activeThumbColor: Colors.teal,
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
                                color: _isMicrograms ? Colors.teal : Colors.grey,
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
                    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Concentración no válida';
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _calculateDose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('CALCULAR DOSIS', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24.0),
                if (_volumeMl != null && _totalDoseMg != null)
                  Card(
                    elevation: 4.0,
                    color: Colors.teal.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            'VOLUMEN A ADMINISTRAR',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${_volumeMl!.toStringAsFixed(3)} ml',
                            style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Divider(height: 30.0),
                          Text(
                            _getDoseResultText(),
                            style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}