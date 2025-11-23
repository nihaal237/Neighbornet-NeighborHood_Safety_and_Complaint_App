import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminCreateAlertScreen extends StatefulWidget {
  const AdminCreateAlertScreen({super.key});

  @override
  State<AdminCreateAlertScreen> createState() => _AdminCreateAlertScreenState();
}

class _AdminCreateAlertScreenState extends State<AdminCreateAlertScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String priority = "Low";
  bool _isLoading = false;

  final Map<String, Color> priorityColors = {
    "Low": Colors.green,
    "Mid": Colors.orange,
    "High": Colors.red,
  };

  Future<void> createAlert() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse("http://127.0.0.1:8000/admin/alerts/");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": titleController.text,
          "message": messageController.text,
          "priority": priority,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("✅ Alert Created!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFA5BCDF),
   appBar: AppBar(
  iconTheme: const IconThemeData(
    color: Colors.white, // <-- MAKES THE BACK ARROW WHITE
  ),
  title: Row(
    children: const [
      Icon(Icons.add_alert, color: Colors.white),
      SizedBox(width: 10),
      Text(
        "Report an Alert",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
    ],
  ),
  backgroundColor: const Color.fromARGB(255, 19, 44, 83),
  elevation: 5,
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title Block
            _buildInputCard(
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter alert title",
                ),
              ),
              icon: Icons.title,
              label: "Title",
            ),
            const SizedBox(height: 15),
            // Message Block
            _buildInputCard(
              child: TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Describe the alert...",
                ),
              ),
              icon: Icons.message,
              label: "Message",
            ),
            const SizedBox(height: 15),
            // Priority Selection
            _buildPriorityCard(),
            const SizedBox(height: 30),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : createAlert,
                icon: const Icon(Icons.send),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
            "Submit Alert",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // move inside TextStyle
            ),
          ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5279C7),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable input card
  Widget _buildInputCard({required Widget child, required IconData icon, required String label}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5279C7)),
            const SizedBox(width: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // Priority selector card
  Widget _buildPriorityCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.priority_high, color: Color(0xFF5279C7)),
            const SizedBox(width: 10),
            const Text(
              "Priority:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Wrap(
                spacing: 15,
                children: priorityColors.keys.map((p) {
                  final isSelected = p == priority;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    selectedColor: priorityColors[p],
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) {
                      setState(() => priority = p);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
