import 'dart:io';

void main() {
  var file = File('lib/ui/screens/support_page.dart');
  var code = file.readAsStringSync();
  
  var newCode = code.replaceAll(
    '''                  Expanded(
                    child: Row(
                      children: [
                        // LIST VIEW (Left Pane)
                        Expanded(
                          flex: 1,
                          child: GlassCard(''',
    '''                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 800;
                        
                        final listPane = Expanded(
                          flex: isMobile ? 1 : 1,
                          child: GlassCard('''
  );

  newCode = newCode.replaceAll(
    '''                      const SizedBox(width: 24),
                      // DETAIL VIEW (Right Pane)
                      Expanded(
                        flex: 2,
                        child: _selectedTicket == null''',
    '''                      
                      final detailPane = Expanded(
                        flex: isMobile ? 1 : 2,
                        child: _selectedTicket == null'''
  );

  newCode = newCode.replaceAll(
    '''                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Ticket #\${_selectedTicket!['id'].toString().substring(0, 8)}', style: const TextStyle(color: Colors.grey)),''',
    '''                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              if (isMobile) ...[
                                                IconButton(
                                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                                  onPressed: () => setState(() => _selectedTicket = null),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Text('Ticket #\${_selectedTicket!['id'].toString().substring(0, 8)}', style: const TextStyle(color: Colors.grey)),
                                            ],
                                          ),'''
  );

  newCode = newCode.replaceAll(
    '''                                    ],
                                  ),
                              ),
                      ),
                    ],
                  ),
          ),''',
    '''                                    ],
                                  ),
                              ),
                      );
                      
                      if (isMobile) {
                        return Row(
                          children: [
                            if (_selectedTicket == null) listPane else detailPane,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          listPane,
                          const SizedBox(width: 24),
                          detailPane,
                        ],
                      );
                    },
                  ),
          ),'''
  );
  
  file.writeAsStringSync(newCode);
}
