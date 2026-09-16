import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VideoSolutionsScreen extends StatefulWidget {
  const VideoSolutionsScreen({super.key});
  @override State<VideoSolutionsScreen> createState() => _VideoSolutionsScreenState();
}

class _VideoSolutionsScreenState extends State<VideoSolutionsScreen> {
  final _db = FirebaseFirestore.instance;
  String? _instituteId;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadInstitute(); }

  Future<void> _loadInstitute() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('admins').doc(uid).get();
      _instituteId = '${doc.data()?['instituteId'] ?? doc.data()?['appId'] ?? ''}';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addOrEdit({DocumentSnapshot<Map<String,dynamic>>? doc}) async {
    final d = doc?.data() ?? {};
    final title = TextEditingController(text: '${d['title'] ?? ''}');
    final subject = TextEditingController(text: '${d['subject'] ?? ''}');
    final url = TextEditingController(text: '${d['videoUrl'] ?? ''}');
    final description = TextEditingController(text: '${d['description'] ?? ''}');
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(doc == null ? 'Add Video Solution' : 'Edit Video Solution'),
      content: SizedBox(width: 500, child: Form(key: form, child: SingleChildScrollView(child: Column(children: [
        TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Video Title'), validator: (v)=>v!.trim().isEmpty?'Required':null),
        TextFormField(controller: subject, decoration: const InputDecoration(labelText: 'Subject / Topic')),
        TextFormField(controller: url, decoration: const InputDecoration(labelText: 'Video URL'), validator: (v)=>v!.trim().isEmpty?'Required':null),
        TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
      ]))),),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')), ElevatedButton(onPressed: ()=>form.currentState!.validate()?Navigator.pop(context,true):null, child: const Text('Save'))],
    ));
    if (ok != true || _instituteId == null || _instituteId!.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ref = doc?.reference ?? _db.collection('video_solutions').doc();
    await ref.set({'title':title.text.trim(),'subject':subject.text.trim(),'videoUrl':url.text.trim(),'description':description.text.trim(),'instituteId':_instituteId,'adminUid':uid,'isActive':true,'updatedAt':FieldValue.serverTimestamp(),if(doc==null)'createdAt':FieldValue.serverTimestamp()}, SetOptions(merge:true));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video solution saved.')));
  }

  Future<void> _delete(DocumentSnapshot<Map<String,dynamic>> doc) async { await doc.reference.delete(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Video Solutions'), backgroundColor: const Color(0xff3730A3), foregroundColor: Colors.white),
    floatingActionButton: FloatingActionButton.extended(onPressed: ()=>_addOrEdit(), icon: const Icon(Icons.add), label: const Text('Add Video')),
    body: _loading ? const Center(child:CircularProgressIndicator()) : _instituteId==null || _instituteId!.isEmpty ? const Center(child:Text('Institute ID is not available.')) : StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
      stream:_db.collection('video_solutions').where('instituteId',isEqualTo:_instituteId).snapshots(),
      builder:(context,snap){ final docs=snap.data?.docs??[]; if(docs.isEmpty)return const Center(child:Text('No video solutions yet. Add your first solution.')); return ListView.separated(padding:const EdgeInsets.all(20),itemCount:docs.length,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(_,i){final d=docs[i].data();return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.play_circle_fill_rounded)),title:Text('${d['title']??'Untitled'}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${d['subject']??''}\n${d['videoUrl']??''}'),isThreeLine:true,trailing:Wrap(children:[IconButton(onPressed:()=>_addOrEdit(doc:docs[i]),icon:const Icon(Icons.edit)),IconButton(onPressed:()=>_delete(docs[i]),icon:const Icon(Icons.delete_outline,color:Colors.red))]));});},
    ),
  );
}
