import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/share_service.dart';
import 'package:app_autismo/models/share_model.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late Future _sharesFuture;
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sharesFuture =
        Provider.of<ShareService>(context, listen: false).fetchShares();
  }

  Future<void> _addShare() async {
    final email = _emailController.text;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um e-mail válido.')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    
    final shareService = Provider.of<ShareService>(context, listen: false);
    bool success = await shareService.createShare(email, 'relatorios'); 

    setState(() { _isLoading = false; });

    if (success) {
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Convite enviado para $email!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar convite.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteShare(int shareId) async {
    setState(() { _isLoading = true; });
    
    final shareService = Provider.of<ShareService>(context, listen: false);
    bool success = await shareService.deleteShare(shareId);

    setState(() { _isLoading = false; });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover compartilhamento.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compartilhar Relatórios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Convidar novo profissional',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail do profissional',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('Enviar Convite'),
                    onPressed: _isLoading ? null : _addShare,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Profissionais com Acesso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: _sharesFuture,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.error != null) {
                        return Center(
                            child: Text('Erro ao carregar lista.'));
                      }

                      return Consumer<ShareService>(
                        builder: (ctx, shareService, child) {
                          if (shareService.shares.isEmpty) {
                            return Center(
                                child: Text('Você não está compartilhando com ninguém.'));
                          }
                          
                          return ListView.builder(
                            itemCount: shareService.shares.length,
                            itemBuilder: (ctx, i) {
                              final share = shareService.shares[i];
                              return ListTile(
                                leading: Icon(Icons.person),
                                title: Text(share.viewerEmail),
                                subtitle: Text('Acesso: ${share.escopo}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteShare(share.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}