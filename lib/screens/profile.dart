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

  Map<String, int> _results = {
    'alphabet': 0,
    'number': 0,
    'operations': 0,
    'parelles': 0,
    'sequencia': 0,
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

      _results['alphabet'] = prefs.getInt('score_alphabet') ?? 0;
      _results['number'] = prefs.getInt('score_number') ?? 0;
      _results['operations'] = prefs.getInt('score_operations') ?? 0;
      _results['parelles'] = prefs.getInt('score_parelles') ?? 0;
      _results['sequencia'] = prefs.getInt('score_sequencia') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('user_name', _nomController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_selectedLanguage == 'cat' ? 'Guardat!' :
      _selectedLanguage == 'esp' ? '¡Guardado!' : 'Saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = _selectedLanguage == 'cat' ? 'Perfil' : _selectedLanguage == 'esp' ? 'Perfil' : 'Profile';
    final String gamesTitle = _selectedLanguage == 'cat' ? 'Resultats' : _selectedLanguage == 'esp' ? 'Resultados' : 'Results';

    InputDecoration _inputStyle(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppStyles.appBarText), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // NOM
                    TextField(
                      controller: _nomController,
                      cursorColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputStyle(
                        _selectedLanguage == 'cat' ? 'Nom' : _selectedLanguage == 'esp' ? 'Nombre' : 'Name',
                        Icons.edit
                      ),
                    ),
                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: Colors.black),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        decoration: _inputStyle(
                          _selectedLanguage == 'cat' ? 'Idioma' : _selectedLanguage == 'esp' ? 'Idioma' : 'Language',
                          Icons.language
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cat', child: Text('Català')),
                          DropdownMenuItem(value: 'esp', child: Text('Español')),
                          DropdownMenuItem(value: 'eng', child: Text('English')),
                        ],
                        onChanged: (val) => setState(() => _selectedLanguage = val!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Botó negre
                        foregroundColor: Colors.white, // Text blanc
                      ),
                      child: Text(_selectedLanguage == 'cat' ? 'Guardar' : _selectedLanguage == 'esp' ? 'Guardar': 'Save'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(gamesTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const Divider(color: Colors.black26),

            _buildResultTile(_selectedLanguage == 'cat' ? 'Alfabètic' : _selectedLanguage == 'esp' ? 'Alfabético' : 'Alphabetic', _results['alphabet']!, Icons.abc),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Numèric' : _selectedLanguage == 'esp' ? 'Numérico' : 'Numbers', _results['number']!, Icons.numbers),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Operacions' : _selectedLanguage == 'esp' ? 'Operaciones' : 'Operations', _results['operations']!, Icons.calculate),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Parelles' : _selectedLanguage == 'esp' ? 'Parejas' : 'Pairs', _results['parelles']!, Icons.extension),
            _buildResultTile(_selectedLanguage == 'cat' ? 'Seqüència' : _selectedLanguage == 'esp' ? 'Secuencia' : 'Sequence', _results['sequencia']!, Icons.repeat),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(String gameName, int score, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(gameName, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        '$score',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }
}