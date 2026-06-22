import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/test_lab_controller.dart';

class SaveRequestDialog extends StatelessWidget {
  final TestLabController controller;

  const SaveRequestDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final url = controller.urlController.text.trim();
    final TextEditingController nameController = TextEditingController(
      text: '${controller.selectedMethod} ${Uri.parse(url).path.split('/').lastOrNull ?? 'Request'}',
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF161622),
      title: const Text('Salvar Requisição'),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nome da Requisição',
          hintText: 'Ex: Listar Usuários',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            Navigator.pop(context);
            if (name.isNotEmpty) {
              controller.saveCurrentRequest(name);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Requisição salva!'),
                  backgroundColor: Colors.teal,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('SALVAR'),
        ),
      ],
    );
  }
}

class CurlExportDialog extends StatefulWidget {
  final TestLabController controller;

  const CurlExportDialog({super.key, required this.controller});

  @override
  State<CurlExportDialog> createState() => _CurlExportDialogState();
}

class _CurlExportDialogState extends State<CurlExportDialog> {
  String selectedFormat = 'Linux (Bash)';
  final formats = ['Linux (Bash)', 'Windows (CMD)', 'Windows (PowerShell)'];

  @override
  Widget build(BuildContext context) {
    final curlCommand = widget.controller.getGeneratedCurl(selectedFormat);
    return AlertDialog(
      backgroundColor: const Color(0xFF161622),
      title: const Row(
        children: [
          Icon(Icons.terminal_rounded, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text('Exportar para cURL'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Formato:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFormat,
                      dropdownColor: const Color(0xFF1A1A24),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurpleAccent),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedFormat = newValue;
                          });
                        }
                      },
                      items: formats.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                curlCommand,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.lightGreenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FECHAR', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: curlCommand));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Comando cURL ($selectedFormat) copiado!'),
                backgroundColor: Colors.teal,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: const Text('COPIAR'),
        ),
      ],
    );
  }
}

class CurlImportDialog extends StatelessWidget {
  final TestLabController controller;

  const CurlImportDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final TextEditingController importController = TextEditingController();

    return AlertDialog(
      backgroundColor: const Color(0xFF161622),
      title: const Row(
        children: [
          Icon(Icons.input_rounded, color: Colors.tealAccent),
          SizedBox(width: 8),
          Text('Importar de cURL'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cole o comando cURL (Linux ou Windows):',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: importController,
            maxLines: 6,
            autofocus: true,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            decoration: const InputDecoration(
              hintText:
                  "curl -X POST 'https://api.exemplo.com' \\\n  -H 'Content-Type: application/json' \\\n  -d '{\"id\": 1}'",
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            final curlText = importController.text;
            Navigator.pop(context);
            if (curlText.trim().isNotEmpty) {
              controller.importFromCurl(curlText);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Requisição cURL importada!'),
                  backgroundColor: Colors.teal,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('IMPORTAR'),
        ),
      ],
    );
  }
}
