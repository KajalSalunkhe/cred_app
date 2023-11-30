import 'package:cred_app/hive_box/boxes.dart';
import 'package:cred_app/model/notes_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text('CRED APP'),
      ),
      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<NotesModel>();
          if (data.isEmpty) {
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
                itemCount: box.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  data[index].title.toString(),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    print("object");
                                    showMyDialog(data[index]);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    delete(data[index]);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              data[index].description.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          showMyDialog(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }

  void showMyDialog(NotesModel? notesModel) {
    if (notesModel != null) {
      titleController.text = notesModel.title;
      descriptionController.text = notesModel.description;
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Padding(
            padding: EdgeInsets.only(
                top: 30,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Title",
                  ),
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Description"),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty) {
                        if (notesModel != null) {
                          notesModel.title = titleController.text;
                          notesModel.description = descriptionController.text;

                          notesModel.save();
                        } else {
                          final data = NotesModel(
                            title: titleController.text,
                            description: descriptionController.text,
                          );

                          final box = Boxes.getData();
                          box.add(data);
                          data.save();
                        }

                        titleController.clear();
                        descriptionController.clear();
                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Required fields'),
                              content: const Text(
                                  'Please fill in both Title and Description.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: SizedBox(
                      width: 100,
                      height: 50,
                      child: Center(
                        child: Text(
                          notesModel != null ? "Edit Data" : "Add Data",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
