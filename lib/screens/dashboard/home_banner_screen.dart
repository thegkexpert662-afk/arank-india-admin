import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeBannerScreen extends StatefulWidget {
  const HomeBannerScreen({super.key});

  @override
  State<HomeBannerScreen> createState() => _HomeBannerScreenState();
}

class _HomeBannerScreenState extends State<HomeBannerScreen> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final buttonTextController = TextEditingController();
  final buttonActionController = TextEditingController();
  final backgroundColorController = TextEditingController();
  final textColorController = TextEditingController();
  final openUrlController = TextEditingController();


  final List<String> bannerColors = [
    "blue",
    "red",
    "green",
    "orange",
    "yellow",
    "purple",
    "pink",
    "brown",
    "grey",
    "black",
    "white",
    "cyan",
    "teal",
    "lime",
    "indigo",
    "amber",
    "deeporange",
    "deeppurple",
    "lightblue",
    "lightgreen",
    "bluegrey",
  ];

  final List<String> textColors = [
    "white",
    "black",
    "grey",
    "blue",
    "red",
    "green",
    "yellow",
  ];
  final List<String> buttonActions = [
    "practice",
    "mock_test",
    "live_test",
    "subjects",
    "leaderboard",
    "profile",
    "website",
    "none",
  ];


  bool isActive = true;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  Future<void> loadBanner() async {
    final doc = await FirebaseFirestore.instance
        .collection("home_banners")
        .doc("banner_1")
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      titleController.text = data["title"] ?? "";
      subtitleController.text = data["subtitle"] ?? "";
      buttonTextController.text = data["buttonText"] ?? "";
      buttonActionController.text = data["buttonAction"] ?? "";
      backgroundColorController.text = data["backgroundColor"] ?? "#2962FF";
      textColorController.text = data["textColor"] ?? "#FFFFFF";
      isActive = data["isActive"] ?? true;
      openUrlController.text = data["openUrl"] ?? "";
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveBanner() async {
    setState(() => saving = true);

    await FirebaseFirestore.instance
        .collection("home_banners")
        .doc("banner_1")
        .update({
      "title": titleController.text.trim(),
      "subtitle": subtitleController.text.trim(),
      "buttonText": buttonTextController.text.trim(),
      "buttonAction": buttonActionController.text.trim(),
      "backgroundColor": backgroundColorController.text.trim(),
      "textColor": textColorController.text.trim(),
      "openUrl": openUrlController.text.trim(),
      "isActive": isActive,
      "imageUrl": "",
      "displayOrder": 1,
      "startDate": Timestamp.now(),
      "endDate": Timestamp.fromDate(
        DateTime(2030, 12, 31),
      ),
    });

    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Banner Updated Successfully")),
    );
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget colorDropdown(
      String label,
      TextEditingController controller,
      List<String> colors,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? colors.first : controller.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: colors.map((color) {
          return DropdownMenuItem(
            value: color,
            child: Text(color),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            controller.text = value!;
          });
        },
      ),
    );
  }

  Widget actionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: buttonActionController.text.isEmpty
            ? buttonActions.first
            : buttonActionController.text,
        decoration: const InputDecoration(
          labelText: "Button Action",
          border: OutlineInputBorder(),
        ),
        items: buttonActions.map((action) {
          return DropdownMenuItem(
            value: action,
            child: Text(action),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            buttonActionController.text = value!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Banner"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            field("Title", titleController),

            field("Subtitle", subtitleController),

            field("Button Text", buttonTextController),

            actionDropdown(),

            if (buttonActionController.text == "website")
              field(
                "Website URL",
                openUrlController,
              ),

            colorDropdown(
              "Background Color",
              backgroundColorController,
              bannerColors,
            ),

            colorDropdown(
              "Text Color",
              textColorController,
              textColors,
            ),

            SwitchListTile(
              title: const Text("Banner Active"),
              value: isActive,
              onChanged: (v) {
                setState(() {
                  isActive = v;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: saving ? null : saveBanner,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "SAVE",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}