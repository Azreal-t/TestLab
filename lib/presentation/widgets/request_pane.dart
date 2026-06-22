import 'package:flutter/material.dart';
import '../controllers/test_lab_controller.dart';
import 'dialogs.dart';

class RequestPane extends StatefulWidget {
  final TestLabController controller;

  const RequestPane({super.key, required this.controller});

  @override
  State<RequestPane> createState() => _RequestPaneState();
}

class _RequestPaneState extends State<RequestPane> with SingleTickerProviderStateMixin {
  late TabController _requestTabController;

  @override
  void initState() {
    super.initState();
    _requestTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _requestTabController.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveRequestDialog(controller: widget.controller),
    );
  }

  void _showCurlDialog() {
    showDialog(
      context: context,
      builder: (context) => CurlExportDialog(controller: widget.controller),
    );
  }

  void _showImportCurlDialog() {
    showDialog(
      context: context,
      builder: (context) => CurlImportDialog(controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                const Text(
                  'Configurar Requisição',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: _showImportCurlDialog,
                  icon: const Icon(Icons.input_rounded, size: 16),
                  label: const Text('Importar cURL'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.tealAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Method Selector & URL Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161622),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedMethod,
                      dropdownColor: const Color(0xFF1A1A24),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurpleAccent),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            controller.selectedMethod = newValue;
                          });
                        }
                      },
                      items: controller.methods.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.urlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: 'Digite a URL (ex: https://api.exemplo.com/dados)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: 'Limpar URL',
                        onPressed: () => controller.urlController.clear(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined, color: Colors.tealAccent),
                    tooltip: 'Salvar Requisição',
                    onPressed: _showSaveDialog,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF161622),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons (Send and cURL)
            LayoutBuilder(
              builder: (context, buttonConstraints) {
                final useVerticalButtons = buttonConstraints.maxWidth < 320;

                Widget sendButton = ElevatedButton(
                  onPressed: controller.isLoading ? null : controller.sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'ENVIAR',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                            ),
                          ],
                        ),
                );

                Widget curlButton = OutlinedButton(
                  onPressed: _showCurlDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurpleAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terminal_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'cURL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );

                if (useVerticalButtons) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 48, child: sendButton),
                      const SizedBox(height: 8),
                      SizedBox(height: 48, child: curlButton),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(height: 48, child: sendButton),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(height: 48, child: curlButton),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Tabs (Headers / Body)
            TabBar(
              controller: _requestTabController,
              tabs: const [
                Tab(text: 'Headers', icon: Icon(Icons.dns_outlined, size: 18)),
                Tab(text: 'Body / Content', icon: Icon(Icons.code_rounded, size: 18)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _requestTabController,
                children: [
                  _buildHeadersTab(controller),
                  _buildBodyTab(controller),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeadersTab(TestLabController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Request Headers',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey),
            ),
            TextButton.icon(
              onPressed: controller.addHeader,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Header'),
              style: TextButton.styleFrom(foregroundColor: Colors.tealAccent),
            ),
          ],
        ),
        Expanded(
          child: controller.headers.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum header configurado.\nClique em "Add Header" para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.headers.length,
                  itemBuilder: (context, index) {
                    final header = controller.headers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      key: ValueKey(header),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: header.keyController,
                              decoration: const InputDecoration(
                                hintText: 'Key',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: header.valueController,
                              decoration: const InputDecoration(
                                hintText: 'Value',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => controller.removeHeader(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBodyTab(TestLabController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Raw Content / JSON Body',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey),
            ),
            TextButton.icon(
              onPressed: () {
                try {
                  controller.prettifyJsonBody();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('JSON formatado!'),
                      backgroundColor: Colors.teal,
                      duration: Duration(seconds: 1),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON Inválido: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.format_align_left, size: 16),
              label: const Text('Prettify JSON'),
              style: TextButton.styleFrom(foregroundColor: Colors.deepPurpleAccent),
            ),
          ],
        ),
        Expanded(
          child: TextField(
            controller: controller.bodyController,
            maxLines: null,
            minLines: 8,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
            decoration: const InputDecoration(
              hintText: '{\n  "key": "value"\n}',
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }
}
