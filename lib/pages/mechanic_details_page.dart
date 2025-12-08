import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'mechanic.dart'; // Import the shared Mechanic class

class MechanicDetailsPage extends StatelessWidget {
  final Mechanic mechanic;
  final Map<String, String> translations;

  const MechanicDetailsPage({super.key, required this.mechanic, required this.translations});

  @override
  Widget build(BuildContext context) {
    String flag = mechanic.location == 'Rwanda' ? '🇷🇼' : '🇰🇪';

    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          mechanic.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 80,
              backgroundImage: mechanic.image.startsWith('http')
                ? NetworkImage(mechanic.image)
                : AssetImage(mechanic.image),
            ),
            const SizedBox(height: 16),
            Text(
              mechanic.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$flag ${mechanic.location}',
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mechanic.specialty,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  CupertinoIcons.star_fill,
                  size: 20,
                  color: index < (mechanic.rating.floor()) ? Colors.amber : Colors.grey,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '${mechanic.rating}/5',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Experience: ${mechanic.experience}',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${mechanic.status}',
              style: TextStyle(
                fontSize: 14,
                color: mechanic.status == 'available' ? Colors.green : mechanic.status == 'busy' ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed Jobs: ${mechanic.completedJobs}',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed Jobs',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...mechanic.jobs.map((job) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['service'] ?? 'Unknown Service',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                            ),
                          ),
                          Text(
                            'Customer: ${job['customerName'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          Text(
                            'Rating: ${job['rating'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          Text(
                            'Feedback: ${job['feedback'] ?? 'No feedback'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}