import 'package:flutter/material.dart';
import '../controllers/test_lab_controller.dart';

class SidebarContent extends StatelessWidget {
  final TestLabController controller;

  const SidebarContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.centerLeft,
                  child: const Row(
                    children: [
                      Icon(Icons.collections_bookmark_rounded, color: Colors.deepPurpleAccent),
                      SizedBox(width: 8),
                      Text(
                        'Coleções & Histórico',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Salvas', icon: Icon(Icons.bookmark_border_rounded, size: 18)),
                  Tab(text: 'Histórico', icon: Icon(Icons.history_rounded, size: 18)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSavedTab(context),
                    _buildHistoryTab(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedTab(BuildContext context) {
    if (controller.savedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma requisição salva',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Clique no ícone de salvar na URL',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: controller.savedRequests.length,
      itemBuilder: (context, index) {
        final req = controller.savedRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          color: const Color(0xFF161622),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12, right: 4),
            title: Text(
              req.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Text(
                  req.method,
                  style: TextStyle(
                    color: _getMethodColor(req.method),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    req.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              onPressed: () => controller.deleteSavedRequest(req.id),
            ),
            onTap: () {
              controller.loadRequest(req);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    if (controller.historyRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'Histórico vazio',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: controller.clearHistory,
              icon: const Icon(Icons.clear_all, size: 16, color: Colors.redAccent),
              label: const Text('Limpar', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: controller.historyRequests.length,
            itemBuilder: (context, index) {
              final req = controller.historyRequests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: const Color(0xFF161622),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Row(
                    children: [
                      Text(
                        req.method,
                        style: TextStyle(
                          color: _getMethodColor(req.method),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _getFormattedTime(req.timestamp),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  ),
                  onTap: () {
                    controller.loadRequest(req);
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getFormattedTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
