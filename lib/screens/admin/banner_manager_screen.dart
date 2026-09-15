import 'package:flutter/material.dart';
import '../../models/banner_model.dart';


class BannerManagerScreen extends StatefulWidget {
  const BannerManagerScreen({super.key});

  @override
  State<BannerManagerScreen> createState() => _BannerManagerScreenState();
}

class _BannerManagerScreenState extends State<BannerManagerScreen> {

  List<BannerModel> banners = List.from(dummyBanners);

  void addBanner() {
    setState(() {
      banners.add(
        BannerModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "New Banner",
          subtitle: "Subtitle",
          buttonText: "Start",
          buttonAction: "practice",
          backgroundColor: "blue",
          textColor: "white",
          openUrl: "",
          active: true,
        ),
      );
    });
  }

  void deleteBanner(int index) {
    setState(() {
      banners.removeAt(index);
    });
  }

  void editBanner(int index) async {
    final banner = banners[index];

    final title = TextEditingController(text: banner.title);
    final subtitle = TextEditingController(text: banner.subtitle);
    final buttonText = TextEditingController(text: banner.buttonText);
    final buttonAction = TextEditingController(text: banner.buttonAction);
    final background = TextEditingController(text: banner.backgroundColor);
    final textColor = TextEditingController(text: banner.textColor);
    final website = TextEditingController(text: banner.openUrl);

    bool active = banner.active;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Banner"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: "Title",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: subtitle,
                      decoration: const InputDecoration(
                        labelText: "Subtitle",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: buttonText,
                      decoration: const InputDecoration(
                        labelText: "Button Text",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: buttonAction,
                      decoration: const InputDecoration(
                        labelText: "Button Action",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: background,
                      decoration: const InputDecoration(
                        labelText: "Background Color",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: textColor,
                      decoration: const InputDecoration(
                        labelText: "Text Color",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: website,
                      decoration: const InputDecoration(
                        labelText: "Website URL",
                      ),
                    ),

                    SwitchListTile(
                      value: active,
                      title: const Text("Active"),
                      onChanged: (v) {
                        setStateDialog(() {
                          active = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      banners[index] = BannerModel(
                        id: banner.id,
                        title: title.text,
                        subtitle: subtitle.text,
                        buttonText: buttonText.text,
                        buttonAction: buttonAction.text,
                        backgroundColor: background.text,
                        textColor: textColor.text,
                        openUrl: website.text,
                        active: active,
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Banner Manager"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addBanner,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(banner.title),
                subtitle: Text(banner.subtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => editBanner(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteBanner(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

  }
