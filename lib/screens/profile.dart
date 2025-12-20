import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.language}) : super(key: key);
  final String language;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nomController = TextEditingController();
  String _selectedLanguage = 'cat';

  Map<String, dynamic> _results = {
    'alphabet': '',
    'number': '',
    'operations': '',
    'parelles': '',
    'sequencia': '',
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

      _results['alphabet'] = _getTime(prefs, 'time_alphabet');
      _results['number'] = _getTime(prefs, 'time_number');
      _results['operations'] = _getTime(prefs, 'time_operations');
      _results['parelles'] = _getTime(prefs, 'time_parelles');
      _results['sequencia'] = _getTime(prefs, 'time_sequencia');
    });
  }

  dynamic _getTime(SharedPreferences prefs, String key) {
    int? time = prefs.getInt(key);
    if (time == null) return '';
    Duration d = Duration(milliseconds: time);
    int m = d.inMinutes;
    int s = d.inSeconds.remainder(60);
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('user_name', _nomController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:
    Colors.lightBlue, shape: RoundedRectangleBorder(borderRadius:
    BorderRadius.circular(10)), content: Text(_selectedLanguage == 'cat' ? 'Guardat!' : _selectedLanguage == 'esp' ? '¡Guardado!' : 'Saved!', style:
    AppStyles.profileSnackBar)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_selectedLanguage == 'cat' ? 'Perfil' :
      _selectedLanguage == 'esp' ? 'Perfil' : 'Profile', style: AppStyles
          .appBarText), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(),
            AppStyles.sizedBoxHeight50,
            Text(_selectedLanguage == 'cat' ? 'Millors Temps' : _selectedLanguage == 'esp' ? 'Mejores Tiempos' : 'Best Times',
                style: AppStyles.resultsProfile),
            const Divider(color: Colors.black26, thickness: 1),
            AppStyles.sizedBoxHeight10,
            _buildResultTile(_selectedLanguage == 'cat' ? 'Alfabètic' : _selectedLanguage == 'esp' ? 'Alfabético' : 'Alphabetic', _results['alphabet'], Icons.abc_rounded),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Numèric' : _selectedLanguage == 'esp' ? 'Numérico' : 'Numbers', _results['number'], Icons.onetwothree_rounded),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Operacions' : _selectedLanguage == 'esp' ? 'Operaciones' : 'Operations', _results['operations'], Icons.calculate_rounded),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Parelles' : _selectedLanguage == 'esp' ? 'Parejas' : 'Pairs', _results['parelles'], Icons.grid_view_rounded),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Seqüència' :
            _selectedLanguage == 'esp' ? 'Secuencias' : 'Sequence', _results['sequencia'], Icons.route_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'cat'
                    ? 'Nom'
                    : _selectedLanguage == 'esp'
                        ? 'Nombre'
                        : 'Name',
                prefixIcon: const Icon(Icons.edit),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                floatingLabelStyle: const TextStyle(color: Colors.black),
              ),
            ),
            AppStyles.sizedBoxHeight20,
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: InputDecoration(labelText: _selectedLanguage == 'cat' ? 'Idioma' : _selectedLanguage == 'esp' ? 'Idioma' : 'Language', labelStyle: TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons
                  .language),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),),
              items: const [DropdownMenuItem(value: 'cat', child: Text('Català')), DropdownMenuItem(value: 'esp', child: Text('Español')), DropdownMenuItem(value: 'eng', child: Text('English'))],
              onChanged: (val) => setState(() => _selectedLanguage = val!),
            ),
            AppStyles.sizedBoxHeight20,
            ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: Text(_selectedLanguage == 'cat' ? 'Guardar' : _selectedLanguage == 'esp' ? 'Guardar' : 'Save')),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(String name, dynamic score, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 35),
        title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ),
      ),
    );
  }
}