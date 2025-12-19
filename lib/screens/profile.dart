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

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.lightBlue,
        //behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          _selectedLanguage == 'cat' ? 'Guardat!' :
          _selectedLanguage == 'esp' ? '¡Guardado!' : 'Saved!',
          style: AppStyles.profileSnackBar
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = _selectedLanguage == 'cat' ? 'Perfil' : _selectedLanguage == 'esp' ? 'Perfil' : 'Profile';
    final String results = _selectedLanguage == 'cat' ? 'Resultats' : _selectedLanguage == 'esp' ? 'Resultados' : 'Results';

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nomController,
                      cursorColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputStyle(
                        _selectedLanguage == 'cat' ? 'Nom' : _selectedLanguage == 'esp' ? 'Nombre' : 'Name',
                        Icons.edit
                      ),
                    ),
                    AppStyles.sizedBoxHeight20,
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
                    AppStyles.sizedBoxHeight20,
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 45),
                      ),
                      child: Text(
                        _selectedLanguage == 'cat' ? 'Guardar' : _selectedLanguage == 'esp' ? 'Guardar' : 'Save',
                        style: AppStyles.saveButton
                      ),
                    )
                  ],
                ),
              ),
            ),
            AppStyles.sizedBoxHeight50,
            Text(results, style: AppStyles.resultsProfile),
            const Divider(color: Colors.black26, thickness: 1),
            AppStyles.sizedBoxHeight10,

            _buildResultTile(
              _selectedLanguage == 'cat' ? 'Alfabètic' : _selectedLanguage == 'esp' ? 'Alfabético' : 'Alphabetic',
              _results['alphabet']!,
              Icons.abc_rounded
            ),
            _buildResultTile(
              _selectedLanguage == 'cat' ? 'Numèric' : _selectedLanguage == 'esp' ? 'Numérico' : 'Numbers',
              _results['number']!,
              Icons.onetwothree_rounded
            ),
            _buildResultTile(
              _selectedLanguage == 'cat' ? 'Operacions' : _selectedLanguage == 'esp' ? 'Operaciones' : 'Operations',
              _results['operations']!,
              Icons.calculate_rounded
            ),
            _buildResultTile(
              _selectedLanguage == 'cat' ? 'Parelles' : _selectedLanguage == 'esp' ? 'Parejas' : 'Pairs',
              _results['parelles']!,
              Icons.grid_view_rounded
            ),
            _buildResultTile(
              _selectedLanguage == 'cat' ? 'Seqüència' : _selectedLanguage == 'esp' ? 'Secuencia' : 'Sequence',
              _results['sequencia']!,
              Icons.route_rounded
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(String gameName, int score, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: Colors.black87,
          size: 35
        ),
        title: Text(
          gameName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent
            ),
          ),
        ),
      ),
    );
  }
}