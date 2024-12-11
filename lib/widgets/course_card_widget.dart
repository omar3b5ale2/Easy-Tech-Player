import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CourseCard extends StatelessWidget {
  final String name;
  final String link;
  final int lessonsCount;
  final bool free;
  final String cover;
  final String description;
  final bool isGrid;

  const CourseCard({
    super.key,
    required this.name,
    required this.lessonsCount,
    required this.free,
    required this.link,

    required this.cover,
    required this.description,
    this.isGrid = false, // Default for list layout
  });

  @override
  Widget build(BuildContext context) {
    // Determine the current breakpoint
    final currentBreakpoint = ResponsiveBreakpoints.of(context).breakpoint.name;

    // Determine trimLines based on breakpoint
    int maxLines;
    switch (currentBreakpoint) {
      case MOBILE:
        maxLines = 1;
        break;
      case TABLET:
        maxLines = 2;
        break;
      case "BIG-TABLET":
        maxLines = 2;
        break;
      case DESKTOP:
        maxLines = 2;
        break;
      default: // '4K'
        maxLines = 2;
    }

    // Responsive layout based on screen size
    double imageHeight = isGrid ? 150 : 100;
    double padding = ResponsiveValue(
      context,
      defaultValue: 12.0,
      conditionalValues: [
        Condition.smallerThan(name: MOBILE, value: 8.0),
        Condition.largerThan(name: TABLET, value: 16.0),
      ],
    ).value;

    double fontSize = ResponsiveValue(
      context,
      defaultValue: 14.0,
      conditionalValues: [
        Condition.smallerThan(name: MOBILE, value: 12.0),
        Condition.largerThan(name: TABLET, value: 16.0),
      ],
    ).value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Ensures the card height adjusts dynamically
        children: [
          // Cover Image (half the size for grid layout)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: FractionallySizedBox(
              alignment: Alignment.center,
              widthFactor: 1, // Image fills the card width
              child: Image.network(
                cover,
                height: imageHeight, // Dynamic height based on grid or list
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Adjust height dynamically
              children: [
                // Course Name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: fontSize + 4, // Increased font size for name
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Row: Lessons Count and Free/Not Free
                Row(
                  children: [
                    Text(
                      'الدروس: $lessonsCount',
                      style: TextStyle(fontSize: fontSize, color: Colors.black54),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          free ? Icons.check_circle : Icons.cancel,
                          color: free ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          free ? 'مجاني' : 'غير مجاني',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description using ReadMoreText
                Text(
                  "الوصف:  $description",
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: fontSize, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
