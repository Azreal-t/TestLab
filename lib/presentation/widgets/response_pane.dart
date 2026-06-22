import 'dart:convert';
import 'package:flutter/material.dart';
import '../controllers/test_lab_controller.dart';

class ResponsePane extends StatelessWidget {
  final TestLabController controller;

  const ResponsePane({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Aguardando resposta...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (controller.response == null && controller.error == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hub_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Configure a requisição e clique em Enviar',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          );
        }

        final int? statusCode = controller.response?.statusCode;
        final bool isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;

        Color statusColor = Colors.redAccent;
        if (isSuccess) {
          statusColor = Colors.green;
        } else if (statusCode != null && statusCode >= 300 && statusCode < 400) {
          statusColor = Colors.orange;
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header of Response Pane
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Resposta:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        if (statusCode != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              '$statusCode ${_getStatusMessage(statusCode)}',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: const Text(
                              'FALHA NA CONEXÃO',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.responseTimeMs != null)
                          _buildMetricChip(Icons.timer_outlined, '${controller.responseTimeMs}ms'),
                        const SizedBox(width: 8),
                        if (controller.response?.data != null)
                          _buildMetricChip(
                            Icons.storage_outlined,
                            _getResponseSizeText(controller.response!.data),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Body', icon: Icon(Icons.receipt_long_outlined, size: 18)),
                  Tab(text: 'Headers', icon: Icon(Icons.dns_outlined, size: 18)),
                  Tab(text: 'Metadados / Erro', icon: Icon(Icons.info_outline_rounded, size: 18)),
                ],
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF0F0F15),
                  child: TabBarView(
                    children: [
                      _buildResponseBodyTab(context),
                      _buildResponseHeadersTab(),
                      _buildResponseInfoTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBodyTab(BuildContext context) {
    if (controller.formattedResponseBody == null || controller.formattedResponseBody!.isEmpty) {
      return Center(
        child: Text(
          'Corpo da resposta vazio',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF151520),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  controller.formattedResponseBody!,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseHeadersTab() {
    final headersMap = controller.response?.headers.map;
    if (headersMap == null || headersMap.isEmpty) {
      return Center(
        child: Text(
          'Nenhum header retornado',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final list = headersMap.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final entry = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          color: const Color(0xFF161622),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: SelectableText(
                    entry.value.join(', '),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
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

  Widget _buildResponseInfoTab() {
    final error = controller.error;
    final response = controller.response;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null) ...[
            const Text(
              'Detalhes do Erro',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                'Tipo: ${error.type}\n'
                'Mensagem: ${error.message}\n'
                'Erro Interno: ${error.error ?? "Nenhum"}',
                style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Informações da Requisição',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'URL Solicitada',
            response?.requestOptions.uri.toString() ??
                error?.requestOptions.uri.toString() ??
                controller.urlController.text,
          ),
          _buildInfoRow(
            'Método',
            response?.requestOptions.method ??
                error?.requestOptions.method ??
                controller.selectedMethod,
          ),
          _buildInfoRow(
            'Tempo de Resposta',
            controller.responseTimeMs != null ? '${controller.responseTimeMs} ms' : 'N/A',
          ),
          if (response != null) ...[
            _buildInfoRow('Redirecionamentos', response.redirects.length.toString()),
            _buildInfoRow('Status Code', response.statusCode.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(int code) {
    switch (code) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return '';
    }
  }

  String _getResponseSizeText(dynamic data) {
    if (data == null) return '0 B';
    int bytes = 0;
    if (data is String) {
      bytes = utf8.encode(data).length;
    } else if (data is List<int>) {
      bytes = data.length;
    } else {
      try {
        final jsonStr = jsonEncode(data);
        bytes = utf8.encode(jsonStr).length;
      } catch (_) {
        bytes = data.toString().length;
      }
    }

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
