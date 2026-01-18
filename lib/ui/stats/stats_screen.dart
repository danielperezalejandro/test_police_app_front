import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final Map<String, dynamic>? statsData;

  const StatsScreen({
    super.key,
    required this.statsData,
  });

  @override
  Widget build(BuildContext context) {
    if (statsData == null) {
      return const Center(
        child: Text(
          'Pulsa en Estadísticas para cargar los datos',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (statsData!['success'] != true) {
      return Center(
        child: Text(
          statsData!['error']?.toString() ??
              'No se pudieron cargar estadísticas',
          textAlign: TextAlign.center,
        ),
      );
    }

    final List<dynamic> types = (statsData!['types'] as List?) ?? [];

    if (types.isEmpty) {
      return const Center(child: Text('Aún no hay estadísticas'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Aciertos y fallos por tipo, y desglose por temas.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        ...types
            .map((t) => _TypeStatsCard(typeData: t as Map<String, dynamic>))
            .toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TypeStatsCard extends StatelessWidget {
  final Map<String, dynamic> typeData;

  const _TypeStatsCard({required this.typeData});

  @override
  Widget build(BuildContext context) {
    final String type = (typeData['type'] ?? '').toString();
    final int total = (typeData['total'] ?? 0) as int;
    final int correct = (typeData['correct'] ?? 0) as int;
    final int wrong = (typeData['wrong'] ?? 0) as int;

    final double correctPercent =
        (typeData['correctPercent'] as num?)?.toDouble() ?? 0.0;
    final double wrongPercent =
        (typeData['wrongPercent'] as num?)?.toDouble() ?? 0.0;

    final topics = (typeData['topics'] as List?) ?? [];

    final progress = (correctPercent / 100).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.blue.withOpacity(0.10),
                  ),
                  child: Text(
                    'TYPE $type',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$correct/$total',
                  style: const TextStyle(color: Colors.black54),
                )
              ],
            ),

            const SizedBox(height: 14),

            // Circular Progress + summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CircularPercent(
                  percent: correctPercent,
                  value: progress,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${correctPercent.toStringAsFixed(1)}% aciertos',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${wrongPercent.toStringAsFixed(1)}% fallos',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),

                      // Mini bars
                      _MiniBar(
                        label: 'Aciertos',
                        value: (correctPercent / 100).clamp(0.0, 1.0),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _MiniBar(
                        label: 'Fallos',
                        value: (wrongPercent / 100).clamp(0.0, 1.0),
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),

                      // Totals
                      Row(
                        children: [
                          _Pill(
                            text: 'Correctas: $correct',
                            bg: Colors.green.withOpacity(0.12),
                            fg: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            text: 'Falladas: $wrong',
                            bg: Colors.red.withOpacity(0.12),
                            fg: Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              'Temas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (topics.isEmpty)
              const Text('Sin datos por tema',
                  style: TextStyle(color: Colors.black54))
            else
              Column(
                children: topics.map((row) {
                  final m = row as Map<String, dynamic>;
                  final topic = (m['topic'] ?? '').toString();
                  final cp = (m['correctPercent'] as num?)?.toDouble() ?? 0.0;
                  final wp = (m['wrongPercent'] as num?)?.toDouble() ?? 0.0;
                  final topicTotal = (m['total'] ?? 0) as int;

                  final topicProgress = (cp / 100).clamp(0.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TopicRow(
                      topic: topic,
                      total: topicTotal,
                      correctPercent: cp,
                      wrongPercent: wp,
                      progress: topicProgress,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircularPercent extends StatelessWidget {
  final double percent;
  final double value;

  const _CircularPercent({required this.percent, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 70
                    ? Colors.green
                    : (percent >= 40 ? Colors.orange : Colors.redAccent),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Text(
                'Aciertos',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  final String topic;
  final int total;
  final double correctPercent;
  final double wrongPercent;
  final double progress;

  const _TopicRow({
    required this.topic,
    required this.total,
    required this.correctPercent,
    required this.wrongPercent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final Color barColor = correctPercent >= 70
        ? Colors.green
        : (correctPercent >= 40 ? Colors.orange : Colors.redAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                topic,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${correctPercent.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Total: $total • Fallos: ${wrongPercent.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
