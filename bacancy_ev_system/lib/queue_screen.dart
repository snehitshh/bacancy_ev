import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'queue_provider.dart';
import 'queue_models.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild the widget every second to update timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    final guns = queueProvider.guns;
    final waitingQueue = queueProvider.waitingQueue;
    final bool allPortsBusy = guns.every((g) => g.status != GunStatus.available);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Queue'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gun Status', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  ...guns.map((gun) => _buildGunStatusCard(context, gun, queueProvider)).toList(),
                  const SizedBox(height: 24),
                  if (waitingQueue.isNotEmpty) ...[
                    Text('Live Queue', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildWaitingQueueList(context, waitingQueue, queueProvider),
                    ),
                  ] else ...[
                    const Center(child: Text("No one in the queue."))
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Waiting Queue'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        queueProvider.joinQueue();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You have been added to the queue! You will be notified when it is your turn.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'You can also reserve a spot by booking in advance.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGunStatusCard(BuildContext context, ChargingGun gun, QueueProvider provider) {
    final statusColor = gun.status == GunStatus.available
        ? Colors.green
        : (gun.status == GunStatus.charging ? Colors.orange : Colors.red);
    final statusText = gun.status.toString().split('.').last.toUpperCase();
    final remainingTime = provider.getEstimatedWaitTimeFor(gun.id);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.ev_station, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gun.id, style: Theme.of(context).textTheme.titleLarge),
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            if (gun.status == GunStatus.charging)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('~${_formatDuration(remainingTime)} left', style: Theme.of(context).textTheme.titleMedium),
                  if (gun.currentUser != null) Text('by ${gun.currentUser!.name}'),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingQueueList(BuildContext context, List<QueueUser> queue, QueueProvider provider) {
    return ListView.builder(
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final user = queue[index];
        final estimatedWait = provider.getEstimatedQueueWaitTime(index);

        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(user.name),
          trailing: Text('~${_formatDuration(estimatedWait)} wait'),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '0m 0s';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${minutes}m ${seconds}s';
  }
} 