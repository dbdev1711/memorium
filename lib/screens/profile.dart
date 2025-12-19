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
    'alphabet': 0,
    'number': 0,
    'operations': '--',
    'parelles': '--',
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
      _results['sequencia'] = prefs.getInt('score_sequencia') ?? 0;

      int? timeParelles = prefs.getInt('time_parelles');
      _results['parelles'] = timeParelles != null ? _formatMillis(timeParelles) : '--';

      int? timeOps = prefs.getInt('time_operations');
      _results['operations'] = timeOps != null ? _formatMillis(timeOps) : '--';
    });
  }

  String _formatMillis(int millis) {
    Duration d = Duration(milliseconds: millis);
    int m = d.inMinutes;
    int s = d.inSeconds.remainder(60);
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('user_name', _nomController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.lightBlue, content: Text('Guardat!', style: AppStyles.profileSnackBar)));
  }

  @override
  Widget build(BuildContext context) {
    final String resultsLabel = _selectedLanguage == 'cat' ? 'Resultats' : 'Results';

    return Scaffold(
      appBar: AppBar(title: Text(_selectedLanguage == 'cat' ? 'Perfil' : 'Profile', style: AppStyles.appBarText), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSettingsCard(),
            AppStyles.sizedBoxHeight50,
            Text(resultsLabel, style: AppStyles.resultsProfile),
            const Divider(color: Colors.black26, thickness: 1),
            AppStyles.sizedBoxHeight10,

            _buildResultTile('Alfabètic', _results['alphabet'], Icons.abc_rounded),
            _buildResultTile('Numèric', _results['number'], Icons.onetwothree_rounded),
            _buildResultTile('Operacions', _results['operations'], Icons.calculate_rounded),
            _buildResultTile('Parelles', _results['parelles'], Icons.grid_view_rounded),
            _buildResultTile('Seqüència', _results['sequencia'], Icons.route_rounded),
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
            TextField(controller: _nomController, decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.edit))),
            AppStyles.sizedBoxHeight20,
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: const [DropdownMenuItem(value: 'cat', child: Text('Català')), DropdownMenuItem(value: 'esp', child: Text('Español')), DropdownMenuItem(value: 'eng', child: Text('English'))],
              onChanged: (val) => setState(() => _selectedLanguage = val!),
            ),
            AppStyles.sizedBoxHeight20,
            ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(String gameName, dynamic score, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 35),
        title: Text(gameName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('$score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ),
      ),
    );
  }
}