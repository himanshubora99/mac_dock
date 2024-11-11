import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock widget with reorderable and animated items.
class Dock extends StatefulWidget {
  final List<IconData> items;

  const Dock({Key? key, required this.items}) : super(key: key);

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _items = List<IconData>.from(widget.items); // Ensure the list is growable.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black38,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          int index = entry.key;
          IconData item = entry.value;
          final isDragging = _draggingIndex == index;

          return LongPressDraggable<IconData>(
            data: item,
            onDragStarted: () {
              print('onDragStarted');
              setState(() => _draggingIndex = index);
            },
            onDragEnd: (_) {
              setState(() => _draggingIndex = null);
            },
            feedback: Material(
              color: Colors.transparent,
              child: _buildDockItem(item, isHovered: true),
            ),
            childWhenDragging: _buildDockItem(item),
            child: DragTarget<IconData>(
              onWillAccept: (data) {
                if (_draggingIndex != null && _draggingIndex != index) {
                  setState(() {
                    final removedItem = _items.removeAt(_draggingIndex!);
                    _items.insert(index, removedItem);
                    _draggingIndex = index;
                  });
                }
                return true;
              },
              onAccept: (data) {},
              builder: (context, candidateData, rejectedData) {
                print('_draggingIndex :: $_draggingIndex : $index');
                if (_draggingIndex == index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }
                return _buildDockItem(item,
                    isHovered: candidateData.isNotEmpty);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDockItem(IconData item, {bool isHovered = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isHovered ? 64 : 48,
      height: isHovered ? 64 : 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.primaries[item.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(item, color: Colors.white, size: isHovered ? 32 : 24),
    );
  }
}
