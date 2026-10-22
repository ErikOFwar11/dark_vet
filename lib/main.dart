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
      title: 'Discalculia Vet',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        cardColor: const Color(0xFF121212),
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

enum ConcentrationType { mgPerMl, grams, percentage }
enum FluidType { ringerLactate, normalSaline, dextroseSaline, custom }

class _DosageCalculatorScreenState extends State<DosageCalculatorScreen> {
  int _currentIndex = 0;

  // Estado para simular / activar la versión Pro
  bool _isProUnlocked = false;

  // ------------------ PESTAÑA DOSIFICACIÓN ------------------
  final GlobalKey<FormState> _dosageFormKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _concentrationController = TextEditingController();

  bool _isMicrograms = false;
  ConcentrationType _selectedConcentrationType = ConcentrationType.mgPerMl;
  double? _volumeMl;
  double? _totalDoseMg;
  double? _finalMgPerMl;

  // ------------------ PESTAÑA FLUIDOTERAPIA ------------------
  final GlobalKey<FormState> _fluidsFormKey = GlobalKey<FormState>();
  final TextEditingController _fluidWeightController = TextEditingController();
  final TextEditingController _dehydrationController = TextEditingController();
  final TextEditingController _maintenanceController = TextEditingController(text: '50');

  FluidType _selectedFluidType = FluidType.ringerLactate;
  int _dropFactor = 20;
  double? _totalFluid24h;
  double? _fluidRateMlHour;
  double? _dropsPerMin;

  // ------------------ PESTAÑA CRI ------------------
  final GlobalKey<FormState> _criFormKey = GlobalKey<FormState>();
  final TextEditingController _criWeightController = TextEditingController();
  final TextEditingController _criDoseController = TextEditingController();
  final TextEditingController _criConcController = TextEditingController();
  final TextEditingController _criBagVolumeController = TextEditingController(text: '500');
  final TextEditingController _criInfusionRateController = TextEditingController(text: '10');

  bool _criIsMicrogramsPerMin = false;
  double? _criDrugVolumeMl;

  // ------------------ PESTAÑA VADEMÉCUM ------------------
  final TextEditingController _searchVademecumController = TextEditingController();
  String _vademecumSearchQuery = '';

  final List<Map<String, String>> _vademecumList = [
    {
      'name': 'Meloxicam (Perros)',
      'species': '🐶 Caninos',
      'category': 'AINE / Analgésico',
      'dose': '0.2',
      'unit': 'mg/kg',
      'route': 'IV / SC / PO',
      'note': 'Dosis inicial. Mantenimiento a 0.1 mg/kg.'
    },
    {
      'name': 'Meloxicam (Gatos)',
      'species': '🐱 Felinos',
      'category': 'AINE / Analgésico',
      'dose': '0.1',
      'unit': 'mg/kg',
      'route': 'SC / PO',
      'note': 'Usar con precaución y evaluación renal previa.'
    },
    {
      'name': 'Ketamina',
      'species': '🐶🐱 Ambos',
      'category': 'Anestésico / Analgésico',
      'dose': '5.0',
      'unit': 'mg/kg',
      'route': 'IV / IM',
      'note': 'Inducción o sedación según combinación.'
    },
    {
      'name': 'Lidocaína',
      'species': '🐶 Caninos',
      'category': 'Anestésico Local / Antiarrítmico',
      'dose': '2.0',
      'unit': 'mg/kg',
      'route': 'IV Lenta',
      'note': 'Evitar en CRI o bolos IV en gatos.'
    },
    {
      'name': 'Maropitant',
      'species': '🐶🐱 Ambos',
      'category': 'Antiemético',
      'dose': '1.0',
      'unit': 'mg/kg',
      'route': 'SC / IV',
      'note': 'Cada 24 horas por máximo 5 días.'
    },
    {
      'name': 'Tramadol',
      'species': '🐶🐱 Ambos',
      'category': 'Analgésico Opioide',
      'dose': '3.0',
      'unit': 'mg/kg',
      'route': 'IV / IM / SC / PO',
      'note': 'Cada 8 - 12 horas.'
    },
    {
      'name': 'Ampicilina',
      'species': '🐶🐱 Ambos',
      'category': 'Antibiótico',
      'dose': '20.0',
      'unit': 'mg/kg',
      'route': 'IV / IM / SC',
      'note': 'Cada 8 horas.'
    },
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _doseController.dispose();
    _concentrationController.dispose();
    _fluidWeightController.dispose();
    _dehydrationController.dispose();
    _maintenanceController.dispose();
    _criWeightController.dispose();
    _criDoseController.dispose();
    _criConcController.dispose();
    _criBagVolumeController.dispose();
    _criInfusionRateController.dispose();
    _searchVademecumController.dispose();
    super.dispose();
  }

  double? _parseFlexibleDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _calculateDose() {
    if (_dosageFormKey.currentState!.validate()) {
      final double weight = _parseFlexibleDouble(_weightController.text) ?? 0.0;
      final double inputDose = _parseFlexibleDouble(_doseController.text) ?? 0.0;
      final double rawConcentration = _parseFlexibleDouble(_concentrationController.text) ?? 1.0;

      setState(() {
        if (_isMicrograms) {
          _totalDoseMg = (weight * inputDose) / 1000.0;
        } else {
          _totalDoseMg = weight * inputDose;
        }

        switch (_selectedConcentrationType) {
          case ConcentrationType.mgPerMl:
            _finalMgPerMl = rawConcentration;
            break;
          case ConcentrationType.grams:
            _finalMgPerMl = rawConcentration * 1000.0;
            break;
          case ConcentrationType.percentage:
            _finalMgPerMl = rawConcentration * 10.0;
            break;
        }

        _volumeMl = (_finalMgPerMl != null && _finalMgPerMl! > 0)
            ? _totalDoseMg! / _finalMgPerMl!
            : 0.0;
      });
    }
  }

  void _calculateFluids() {
    if (_fluidsFormKey.currentState!.validate()) {
      final double weight = _parseFlexibleDouble(_fluidWeightController.text) ?? 0.0;
      final double dehydrationPct = _parseFlexibleDouble(_dehydrationController.text) ?? 0.0;
      final double maintenanceMlKg = _parseFlexibleDouble(_maintenanceController.text) ?? 50.0;

      setState(() {
        final double deficitMl = weight * dehydrationPct * 10.0;
        final double maintenanceMl = weight * maintenanceMlKg;

        _totalFluid24h = deficitMl + maintenanceMl;
        _fluidRateMlHour = _totalFluid24h! / 24.0;
        _dropsPerMin = (_fluidRateMlHour! * _dropFactor) / 60.0;
      });
    }
  }

  void _calculateCri() {
    if (_criFormKey.currentState!.validate()) {
      final double weight = _parseFlexibleDouble(_criWeightController.text) ?? 0.0;
      final double dose = _parseFlexibleDouble(_criDoseController.text) ?? 0.0;
      final double drugConcMgMl = _parseFlexibleDouble(_criConcController.text) ?? 1.0;
      final double bagVolMl = _parseFlexibleDouble(_criBagVolumeController.text) ?? 500.0;
      final double infusionRateMlH = _parseFlexibleDouble(_criInfusionRateController.text) ?? 10.0;

      setState(() {
        double mgPerHour = 0.0;
        if (_criIsMicrogramsPerMin) {
          mgPerHour = (dose * weight * 60.0) / 1000.0;
        } else {
          mgPerHour = dose * weight;
        }

        final double hoursBagLasts = bagVolMl / infusionRateMlH;
        final double totalMgNeededInBag = mgPerHour * hoursBagLasts;
        _criDrugVolumeMl = totalMgNeededInBag / drugConcMgMl;
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
      _finalMgPerMl = null;
      _isMicrograms = false;
      _selectedConcentrationType = ConcentrationType.mgPerMl;

      _fluidWeightController.clear();
      _dehydrationController.clear();
      _totalFluid24h = null;
      _fluidRateMlHour = null;
      _dropsPerMin = null;

      _criWeightController.clear();
      _criDoseController.clear();
      _criConcController.clear();
      _criDrugVolumeMl = null;
    });
  }

  String _getConcentrationLabel() {
    switch (_selectedConcentrationType) {
      case ConcentrationType.mgPerMl:
        return 'Concentración del frasco (mg/mL)';
      case ConcentrationType.grams:
        return 'Concentración en gramos (g)';
      case ConcentrationType.percentage:
        return 'Concentración en porcentaje (%)';
    }
  }

  String _getFluidTypeName(FluidType type) {
    switch (type) {
      case FluidType.ringerLactate:
        return 'Ringer Lactato (Hartmann)';
      case FluidType.normalSaline:
        return 'Cloruro de Sodio 0.9% (Salino)';
      case FluidType.dextroseSaline:
        return 'Solución Glucosalina / Mixta';
      case FluidType.custom:
        return 'Otro / Personalizado';
    }
  }

  String _getFluidClinicalNote(FluidType type) {
    switch (type) {
      case FluidType.ringerLactate:
        return '• Indicado: Cristaloides de elección (cirugía, deshidratación general, acidosis leve).\n• Precaución: Evitar en insuficiencia hepática grave o hipercalcemia.';
      case FluidType.normalSaline:
        return '• Indicado: Alcalosis metabólica, hipercalcemia, traumatismo craneoencefálico.\n• Precaución: Riesgo de acidosis hiperclorémica en infusiones masivas.';
      case FluidType.dextroseSaline:
        return '• Indicado: Neonatos, pacientes pediátricos, hipoglucemia o sepsis.\n• Precaución: No administrar en bolos rápidos.';
      case FluidType.custom:
        return '• Evaluar osmolaridad y compatibilidad con electrolitos agregados.';
    }
  }

  void _showProPaywallDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Desbloquea $featureName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.tealAccent : Colors.teal.shade800,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Obtén acceso ilimitado a Fluidoterapia, CRI y Vademécum interactivo.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.teal.shade900.withValues(alpha: 0.4) : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal),
                ),
                child: const Column(
                  children: [
                    Text(
                      'PRUEBA DE 7 DÍAS GRATIS',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Luego solo \$2.00 USD / mes. Cancela en cualquier momento desde Google Play.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isProUnlocked = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⭐ ¡Prueba de 7 días activada! Disfruta la versión Pro.'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('INICIAR 7 DÍAS GRATIS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddDrugDialog() {
    if (!_isProUnlocked) {
      _showProPaywallDialog('Añadir Fármaco al Vademécum');
      return;
    }

    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedSpecies = '🐶 Caninos';
    String selectedUnit = 'mg/kg';
    String selectedRoute = 'IV / IM / SC';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      backgroundColor: widget.isDarkMode ? const Color(0xFF181818) : Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Añadir Nuevo Fármaco',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del fármaco',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedSpecies,
                            decoration: const InputDecoration(
                              labelText: 'Especie',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: '🐶 Caninos', child: Text('🐶 Perros')),
                              DropdownMenuItem(value: '🐱 Felinos', child: Text('🐱 Gatos')),
                              DropdownMenuItem(value: '🐶🐱 Ambos', child: Text('🐶🐱 Ambos')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedSpecies = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unidad',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'mg/kg', child: Text('mg/kg')),
                              DropdownMenuItem(value: 'mcg/kg', child: Text('mcg/kg')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: doseCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Dosis',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedRoute,
                            decoration: const InputDecoration(
                              labelText: 'Vía principal',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'IV / IM / SC', child: Text('IV / IM / SC')),
                              DropdownMenuItem(value: 'IV (Intravenosa)', child: Text('IV únicamente')),
                              DropdownMenuItem(value: 'IM (Intramuscular)', child: Text('IM únicamente')),
                              DropdownMenuItem(value: 'SC (Subcutánea)', child: Text('SC únicamente')),
                              DropdownMenuItem(value: 'PO (Vía Oral)', child: Text('PO (Oral)')),
                              DropdownMenuItem(value: 'IV / PO', child: Text('IV / PO')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedRoute = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Categoría (Ej. Antibiótico)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notas o precauciones',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty && doseCtrl.text.isNotEmpty) {
                          setState(() {
                            _vademecumList.add({
                              'name': nameCtrl.text,
                              'species': selectedSpecies,
                              'category': categoryCtrl.text.isEmpty ? 'General' : categoryCtrl.text,
                              'dose': doseCtrl.text,
                              'unit': selectedUnit,
                              'route': selectedRoute,
                              'note': noteCtrl.text.isEmpty ? 'Fármaco personalizado.' : noteCtrl.text,
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${nameCtrl.text} añadido al Vademécum.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('GUARDAR FÁRMACO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onNavigationTapped(int index) {
    if ((index == 1 || index == 2 || index == 3) && !_isProUnlocked) {
      String name = 'Módulo Clínico';
      if (index == 1) name = 'Fluidoterapia PRO';
      if (index == 2) name = 'Infusión Continua (CRI)';
      if (index == 3) name = 'Vademécum Dinámico PRO';

      _showProPaywallDialog(name);
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 1:
        return _buildFluidotherapyTab();
      case 2:
        return _buildCriTab();
      case 3:
        return _buildVademecumTab();
      case 0:
      default:
        return _buildDosageTab();
    }
  }

  // PESTAÑA 0: DOSIFICACIÓN
  Widget _buildDosageTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _dosageFormKey,
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
                  labelText: _getConcentrationLabel(),
                  prefixIcon: const Icon(Icons.science),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ConcentrationType>(
                        value: _selectedConcentrationType,
                        icon: const Icon(Icons.arrow_drop_down),
                        borderRadius: BorderRadius.circular(10.0),
                        onChanged: (ConcentrationType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedConcentrationType = newValue;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ConcentrationType.mgPerMl,
                            child: Text('mg/mL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                          ),
                          DropdownMenuItem(
                            value: ConcentrationType.grams,
                            child: Text('Gramos (g)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                          ),
                          DropdownMenuItem(
                            value: ConcentrationType.percentage,
                            child: Text('Porcentaje (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'RESULTADO CLÍNICO',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                            ),
                          ),
                        ),
                        const Divider(height: 20.0),
                        Text('• Dosis total requerida: ${_totalDoseMg!.toStringAsFixed(2)} mg'),
                        if (_selectedConcentrationType == ConcentrationType.grams)
                          const Text('• Conversión aplicada: g × 1000 = mg'),
                        if (_selectedConcentrationType == ConcentrationType.percentage)
                          Text('• Conversión aplicada: ${_concentrationController.text}% × 10 = ${_finalMgPerMl!.toStringAsFixed(1)} mg/mL'),
                        const SizedBox(height: 12.0),
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'VOLUMEN A ADMINISTRAR',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey),
                              ),
                              Text(
                                '${_volumeMl!.toStringAsFixed(3)} mL',
                                style: TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32.0),
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
    );
  }

  // PESTAÑA 1: FLUIDOTERAPIA
  Widget _buildFluidotherapyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _fluidsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: widget.isDarkMode ? const Color(0xFF1A2626) : Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.teal, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Selección de Solución y Plan de Fluidos (24h)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      if (!_isProUnlocked)
                        const Icon(Icons.lock, color: Colors.amber, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tipo de Solución / Cristaloides',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  prefixIcon: const Icon(Icons.medical_services),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FluidType>(
                    value: _selectedFluidType,
                    isExpanded: true,
                    onChanged: (FluidType? val) {
                      if (val != null) {
                        setState(() {
                          _selectedFluidType = val;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: FluidType.ringerLactate,
                        child: Text('Ringer Lactato (Hartmann)'),
                      ),
                      DropdownMenuItem(
                        value: FluidType.normalSaline,
                        child: Text('Cloruro de Sodio 0.9% (Salino)'),
                      ),
                      DropdownMenuItem(
                        value: FluidType.dextroseSaline,
                        child: Text('Solución Glucosalina / Mixta'),
                      ),
                      DropdownMenuItem(
                        value: FluidType.custom,
                        child: Text('Otro / Personalizado'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fluidWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso del paciente (kg)',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Ingrese el peso' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dehydrationController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Deshidratación estimada (%)',
                  prefixIcon: const Icon(Icons.invert_colors),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  hintText: 'Ej. 5, 8 o 10',
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Ingrese el % de deshidratación' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maintenanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Tasa de Mantenimiento (mL/kg/día)',
                  prefixIcon: const Icon(Icons.timer),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Ingrese la tasa' : null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Factor de Goteo del Equipo',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  prefixIcon: const Icon(Icons.opacity),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _dropFactor,
                    isExpanded: true,
                    onChanged: (int? val) {
                      if (val != null) {
                        setState(() {
                          _dropFactor = val;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 20, child: Text('Normogotero Estándar (20 gtt/mL)')),
                      DropdownMenuItem(value: 60, child: Text('Microgotero Pediátrico (60 gtt/mL)')),
                      DropdownMenuItem(value: 10, child: Text('Macrogotero Sangre/Denso (10 gtt/mL)')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateFluids,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                  foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                child: const Text('CALCULAR FLUIDOS', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              if (_totalFluid24h != null)
                Card(
                  elevation: 4.0,
                  color: widget.isDarkMode ? const Color(0xFF1E2929) : Colors.teal.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'PLAN DE FLUIDOTERAPIA',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                            ),
                          ),
                        ),
                        const Divider(height: 20.0),
                        Text('• Solución: ${_getFluidTypeName(_selectedFluidType)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('• Volumen total 24h: ${_totalFluid24h!.toStringAsFixed(1)} mL'),
                        Text('• Velocidad requerida: ${_fluidRateMlHour!.toStringAsFixed(1)} mL/h'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getFluidClinicalNote(_selectedFluidType),
                            style: TextStyle(fontSize: 12.5, color: widget.isDarkMode ? Colors.tealAccent : Colors.teal.shade900),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              const Text('VELOCIDAD DE GOTEO', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                              Text(
                                '${_dropsPerMin!.toStringAsFixed(0)} gtt/min',
                                style: TextStyle(
                                  fontSize: 34.0,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '(Aproximadamente 1 gota cada ${(60 / _dropsPerMin!).toStringAsFixed(1)} segundos)',
                                style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // PESTAÑA 2: CRI
  Widget _buildCriTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _criFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: widget.isDarkMode ? const Color(0xFF1A2626) : Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.teal, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Infusión Continua (CRI) para Suero / Bomba',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      if (!_isProUnlocked)
                        const Icon(Icons.lock, color: Colors.amber, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _criWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso del paciente (kg)',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Ingrese el peso' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _criDoseController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _criIsMicrogramsPerMin ? 'Dosis (mcg/kg/min)' : 'Dosis (mg/kg/h)',
                        prefixIcon: const Icon(Icons.speed),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Ingrese la dosis' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _criIsMicrogramsPerMin = !_criIsMicrogramsPerMin;
                          });
                        },
                        child: Text(
                          _criIsMicrogramsPerMin ? 'mcg/kg/min' : 'mg/kg/h',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _criConcController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Concentración del fármaco (mg/mL)',
                  prefixIcon: const Icon(Icons.science),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Ingrese la concentración' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _criBagVolumeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Volumen Suero (mL)',
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _criInfusionRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Tasa Infusión (mL/h)',
                        prefixIcon: const Icon(Icons.play_arrow),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateCri,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                  foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                child: const Text('CALCULAR ADICIÓN DE FÁRMACO', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              if (_criDrugVolumeMl != null)
                Card(
                  elevation: 4.0,
                  color: widget.isDarkMode ? const Color(0xFF1E2929) : Colors.teal.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'AGREGAR A LA BOLSA DE SUERO',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_criDrugVolumeMl!.toStringAsFixed(2)} mL',
                          style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Extraer ${_criDrugVolumeMl!.toStringAsFixed(2)} mL del fármaco y mezclar en la bolsa de ${_criBagVolumeController.text} mL.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // PESTAÑA 3: VADEMÉCUM PRO
  Widget _buildVademecumTab() {
    final filteredList = _vademecumList.where((item) {
      final name = item['name']!.toLowerCase();
      final category = item['category']!.toLowerCase();
      final species = item['species']!.toLowerCase();
      final route = item['route']!.toLowerCase();
      final query = _vademecumSearchQuery.toLowerCase();
      return name.contains(query) || category.contains(query) || species.contains(query) || route.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchVademecumController,
            onChanged: (value) {
              setState(() {
                _vademecumSearchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Buscar fármaco, vía (IV, IM, SC) o especie...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode ? Colors.teal.shade900 : Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['species'] ?? '🐶 Caninos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.isDarkMode ? Colors.tealAccent : Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Categoría: ${item['category']}',
                          style: TextStyle(color: widget.isDarkMode ? Colors.tealAccent : Colors.teal),
                        ),
                        const SizedBox(height: 6),
                        Text('• Dosis base: ${item['dose']} ${item['unit']}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('• Vía: ', style: TextStyle(fontWeight: FontWeight.w500)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode ? const Color(0xFF2B3A3A) : Colors.teal.shade50,
                                border: Border.all(color: widget.isDarkMode ? Colors.tealAccent : Colors.teal),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['route'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDarkMode ? Colors.tealAccent : Colors.teal.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item['note'] != null) ...[
                          const SizedBox(height: 6),
                          Text('• Nota: ${item['note']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () {
                        setState(() {
                          _doseController.text = item['dose']!;
                          _isMicrograms = item['unit'] == 'mcg/kg';
                          _currentIndex = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dosis de ${item['name']} cargada en la calculadora.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Discalculia Vet'),
            if (_isProUnlocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
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
      body: _buildBodyContent(),

      floatingActionButton: _currentIndex == 3
          ? FloatingActionButton.extended(
        onPressed: _showAddDrugDialog,
        backgroundColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
        foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        icon: Icon(_isProUnlocked ? Icons.add : Icons.lock),
        label: Text(_isProUnlocked ? 'Añadir Fármaco' : 'Añadir Fármaco (PRO)'),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : Colors.white,
        selectedItemColor: widget.isDarkMode ? Colors.tealAccent : Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Dosis',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.water_drop_outlined),
                if (!_isProUnlocked)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.lock, size: 10, color: Colors.amber),
                  ),
              ],
            ),
            label: 'Fluido PRO',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.access_time_filled_outlined),
                if (!_isProUnlocked)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.lock, size: 10, color: Colors.amber),
                  ),
              ],
            ),
            label: 'CRI PRO',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.menu_book),
                if (!_isProUnlocked)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.lock, size: 10, color: Colors.amber),
                  ),
              ],
            ),
            label: 'Vademécum PRO',
          ),
        ],
      ),
    );
  }
}