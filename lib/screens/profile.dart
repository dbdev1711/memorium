import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.language});
  final String language;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nomController = TextEditingController();
  String _selectedLanguage = 'cat';

  final Map<String, Map<String, String>> _results = {
    'number': {'Facil': '-', 'Mitja': '-', 'Dificil': '-'},
    'operations': {'Facil': '-', 'Mitja': '-', 'Dificil': '-'},
    'parelles': {'Facil': '-', 'Mitja': '-', 'Dificil': '-'},
    'sequencia': {'Facil': '-', 'Mitja': '-', 'Dificil': '-'},
  };

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'cat';
      _nomController.text = prefs.getString('user_name') ?? '';

      _results['number'] = _getAllLevels(prefs, 'time_number');
      _results['operations'] = _getAllLevels(prefs, 'time_operations');
      _results['parelles'] = _getAllLevels(prefs, 'time_parelles');
      _results['sequencia'] = _getAllLevels(prefs, 'time_sequencia');
    });
  }

  Map<String, String> _getAllLevels(SharedPreferences prefs, String prefix) {
    return {
      'Facil': _formatMs(prefs.getInt('${prefix}_Facil')),
      'Mitja': _formatMs(prefs.getInt('${prefix}_Mitja')),
      'Dificil': _formatMs(prefs.getInt('${prefix}_Dificil')),
    };
  }

  String _formatMs(int? ms) {
    if (ms == null) return '-';
    Duration d = Duration(milliseconds: ms);
    int m = d.inMinutes;
    int s = d.inSeconds.remainder(60);
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('user_name', _nomController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.lightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
            _selectedLanguage == 'cat' ? 'Guardat!' : _selectedLanguage == 'esp' ? '¡Guardado!' : 'Saved!',
            style: AppStyles.profileSnackBar)));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _selectedLanguage == 'cat' ? 'Perfil' : _selectedLanguage == 'esp' ? 'Perfil' : 'Profile',
              style: AppStyles.appBarText
          ),
          centerTitle: true
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              AppStyles.sizedBoxHeight20,
              _buildSettingsCard(),
              AppStyles.sizedBoxHeight60,
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _selectedLanguage == 'cat' ? 'Millors Temps' : _selectedLanguage == 'esp' ? 'Mejores Tiempos' : 'Best Times',
                  style: AppStyles.resultsProfile
                ),
              ),
              AppStyles.sizedBoxHeight20,
              _buildTableHeader(),
              const Divider(),
              _buildGameRow(_selectedLanguage == 'cat' ? 'Numèric' : _selectedLanguage == 'esp' ? 'Numérico' : 'Numbers', _results['number']!, Icons.onetwothree_rounded),
              _buildGameRow(_selectedLanguage == 'cat' ? 'Operacions' : _selectedLanguage == 'esp' ? 'Operaciones' : 'Operations', _results['operations']!, Icons.calculate_rounded),
              _buildGameRow(_selectedLanguage == 'cat' ? 'Parelles' : _selectedLanguage == 'esp' ? 'Parejas' : 'Pairs', _results['parelles']!, Icons.grid_view_rounded),
              _buildGameRow(_selectedLanguage == 'cat' ? 'Seqüència' : _selectedLanguage == 'esp' ? 'Secuencia' : 'Sequence', _results['sequencia']!, Icons.route_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(_selectedLanguage == 'cat' ? 'Joc' : _selectedLanguage == 'esp' ? 'Juego' : 'Game', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(_selectedLanguage == 'cat' ? 'Fàcil' : _selectedLanguage == 'esp' ? 'Fácil' : 'Easy', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 24))))),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(_selectedLanguage == 'cat' ? 'Mitjà' : _selectedLanguage == 'esp' ? 'Medio' : 'Medium', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 24))))),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(_selectedLanguage == 'cat' ? 'Difícil' : _selectedLanguage == 'esp' ? 'Difícil' : 'Hard', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 24))))),
        ],
      ),
    );
  }

  Widget _buildGameRow(String name, Map<String, String> levels, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(levels['Facil']!, style: const TextStyle(fontSize: 19))))),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(levels['Mitja']!, style: const TextStyle(fontSize: 19))))),
          Expanded(flex: 2, child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(levels['Dificil']!, style: const TextStyle(fontSize: 19))))),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'cat' ? 'Nom' : _selectedLanguage == 'esp' ? 'Nombre' : 'Name',
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            AppStyles.sizedBoxHeight20,
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              isExpanded: true,
              decoration: InputDecoration(
                labelStyle: const TextStyle(fontSize: 16),
                labelText: _selectedLanguage == 'cat' ? 'Idioma' : _selectedLanguage == 'esp' ? 'Idioma' : 'Language',
                prefixIcon: const Icon(Icons.language),
              ),
              selectedItemBuilder: (BuildContext context) {
                return ['cat', 'esp', 'eng'].map<Widget>((String item) {
                  String text = item == 'cat' ? 'Català' : item == 'esp' ? 'Español' : 'English';
                  return Text(
                    text,
                    style: const TextStyle(fontSize: 16),
                  );
                }).toList();
              },
              items: const [
                DropdownMenuItem(
                  value: 'cat',
                  child: Text('Català', style: TextStyle(fontSize: 16))
                ),
                DropdownMenuItem(
                  value: 'esp',
                  child: Text('Español', style: TextStyle(fontSize: 16))
                ),
                DropdownMenuItem(
                  value: 'eng',
                  child: Text('English', style: TextStyle(fontSize: 16))
                ),
              ],
              onChanged: (val) => setState(() => _selectedLanguage = val!),
            ),
            AppStyles.sizedBoxHeight20,
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_selectedLanguage == 'cat' ? 'Guardar' : _selectedLanguage == 'esp' ? 'Guardar' : 'Save', style: TextStyle(fontSize: 18))
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}