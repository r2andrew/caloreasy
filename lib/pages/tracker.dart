import 'package:caloreasy/pages/add_food.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Tracker')),
        backgroundColor: Colors.black,
      ),
      
      // tap to open add food page
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddFoodPage()
            ))
          },
          child: Icon(Icons.add, color: Colors.black,),
      ),
      
      body: Text('tracker page'),
    );
  }
}
