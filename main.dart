import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.teal, 
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(HealthMonitoringApp());
}

class HealthMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitoring App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HealthLogScreen(),
    );
  }
}

class HealthLogScreen extends StatefulWidget {
  @override
  _HealthLogScreenState createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends State<HealthLogScreen> {
  final _heartRateController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _symptomController = TextEditingController();

  String _aiResponse = "No response yet";
  String _timestamp = "";
  bool _isLoading = false; // To track loading state

  Future<void> _getAIResponse() async {
    final heartRate = _heartRateController.text;
    final systolic = _systolicController.text;
    final diastolic = _diastolicController.text;
    final symptoms = _symptomController.text;

    if (heartRate.isEmpty || systolic.isEmpty || diastolic.isEmpty || symptoms.isEmpty) {
      setState(() {
        _aiResponse = "Please fill in all fields!";
      });
      return;
    }

    if (double.tryParse(heartRate) == null || double.tryParse(systolic) == null || double.tryParse(diastolic) == null) {
      setState(() {
        _aiResponse = "Please enter valid numbers for Heart Rate and Blood Pressure.";
      });
      return;
    }

    String inputText = "Patient has a heart rate of $heartRate bpm, systolic blood pressure of $systolic mmHg, "
        "diastolic blood pressure of $diastolic mmHg, and reports symptoms of $symptoms. "
        "Please analyze the data and provide potential diagnosis or suggestions for further action.";

    setState(() {
      _isLoading = true; 
    });

    try {
      var response = await http.post(
        Uri.parse('http://192.168.0.9:3000/ai-analysis'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputText': inputText,
        }),
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        setState(() {
          _aiResponse = result['content'][0]['text'];
          _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        });
      } else {
        setState(() {
          _aiResponse = "Failed to get a response from AI.";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Monitoring App'),
        centerTitle: true,
        backgroundColor: Colors.teal[800], 
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        height: double.infinity, // Prevent white space
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInputFields(),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator() 
                    : ElevatedButton(
                        onPressed: _getAIResponse,
                        child: Text('Get AI Health Analysis'),
                      ),
                SizedBox(height: 20),
                _buildInputDataCard(),
                SizedBox(height: 20),
                _buildAIResponseCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField('Enter Heart Rate', _heartRateController, TextInputType.number),
        _buildInputField('Enter Systolic BP', _systolicController, TextInputType.number),
        _buildInputField('Enter Diastolic BP', _diastolicController, TextInputType.number),
        _buildInputField('Describe Any Discomfort or Symptoms', _symptomController, TextInputType.text),
      ],
    );
  }

  Widget _buildInputDataCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('Health Data', 20, FontWeight.bold),
            SizedBox(height: 10),
            _buildText('Heart Rate: ${_heartRateController.text} bpm', 16, FontWeight.normal),
            _buildText('Systolic Blood Pressure: ${_systolicController.text} mmHg', 16, FontWeight.normal),
            _buildText('Diastolic Blood Pressure: ${_diastolicController.text} mmHg', 16, FontWeight.normal),
            _buildText('Symptoms: ${_symptomController.text}', 16, FontWeight.normal),
            if (_timestamp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildText('Recorded at: $_timestamp', 14, FontWeight.normal),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIResponseCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('AI Health Analysis', 20, FontWeight.bold),
            SizedBox(height: 10),
            Text(
              _aiResponse,
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: weight),
    );
  }
}
