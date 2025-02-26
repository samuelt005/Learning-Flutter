import 'package:flutter/material.dart';
import 'LRUCache.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('LRU Cache em Flutter')),
        body: CacheExample(),
      ),
    );
  }
}

class CacheExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cache = LRUCache<String, String>(3);

    cache.put("1", "Item 1");
    cache.put("2", "Item 2");
    cache.put("3", "Item 3");
    cache.put("4", "Item 4");

    final item1 = cache.get("1");
    final item2 = cache.get("2");
    final item3 = cache.get("3");
    final item4 = cache.get("4");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Item 1: $item1"),
        Text("Item 2: $item2"),
        Text("Item 3: $item3"),
        Text("Item 4: $item4"),
      ],
    );
  }
}
