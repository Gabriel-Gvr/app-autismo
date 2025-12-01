import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/psychologist_service.dart';

class MChatScreen extends StatefulWidget {
  final int assessmentId; 

  const MChatScreen({Key? key, required this.assessmentId}) : super(key: key);

  @override
  _MChatScreenState createState() => _MChatScreenState();
}

class _MChatScreenState extends State<MChatScreen> {
  bool _isLoading = false;
  
  final List<String> _questions = [
    "1. A criança gosta de se balançar, de pular no seu joelho, etc.?",
    "2. Tem interesse por outras crianças?",
    "3. Gosta de subir em coisas, como escadas ou móveis?",
    "4. Gosta de brincar de esconder e mostrar o rosto ou esconde-esconde?",
    "5. Já brincou de faz-de-conta, como, por exemplo, fazer de conta que está falando no telefone?",
    "6. Já usou o dedo indicador para apontar, para pedir alguma coisa?",
    "7. Já usou o dedo indicador para apontar, para indicar interesse em algo?",
    "8. Consegue brincar de forma correta com brinquedos pequenos (ex.: carros ou blocos) sem apenas colocar na boca?",
    "9. Alguma vez trouxe objetos para você (pais) para mostrá-los?",
    "10. Olha para você nos olhos por mais de um segundo ou dois?",
    "11. Já pareceu muito sensível ao barulho (ex.: tapando os ouvidos)?",
    "12. Sorri como resposta às suas expressões facíais ou ao seu sorriso?",
    "13. Imita você (ex.: você faz expressões/caretas e ela o imita?)",
    "14. Responde/olha quando você a chama pelo nome?",
    "15. Se você apontar para um brinquedo do outro lado da sala, a criança acompanha com o olhar?",
    "16. Já sabe andar?",
    "17. Olha para coisas que você está olhando?",
    "18. Faz movimentos estranhos perto do rosto dele?",
    "19. Tenta atrair a sua atenção para a atividade dele?",
    "20. Você alguma vez já se perguntou se a sua criança é surda?",
    "21. Entende o que as pessoas dizem?",
    "22. Às vezes fica aérea, 'olhando para o nada' ou caminhando sem direção?",
    "23. Olha para o seu rosto para conferir a sua reação quando vê algo estranho?",
  ];

  final Map<int, bool?> _answers = {};

  Future<void> _submitMChat() async {
    if (_answers.length < 23 || _answers.containsValue(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responda todas as 23 perguntas.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final Map<String, String> apiAnswers = {};
    _answers.forEach((key, value) {
      apiAnswers[(key + 1).toString()] = value! ? 'sim' : 'nao';
    });

    final psychService = Provider.of<PsychologistService>(context, listen: false);
    bool success = await psychService.saveMchatResults(widget.assessmentId, apiAnswers);

    setState(() { _isLoading = false; });

    if (success && mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('M-CHAT Finalizado'),
          content: Text('A avaliação (Anamnese + M-CHAT) foi salva com sucesso.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      Navigator.of(context).pop(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o M-CHAT.'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('M-CHAT (Avaliação)'),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 100.0), 
              itemCount: _questions.length, 
              itemBuilder: (context, index) {
                final question = _questions[index];
                final answer = _answers[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ChoiceChip(
                              label: Text('Sim'),
                              selected: answer == true,
                              onSelected: (isSelected) {
                                setState(() { _answers[index] = true; });
                              },
                              selectedColor: Colors.green[100],
                            ),
                            SizedBox(width: 8),
                            // Botão NÃO
                            ChoiceChip(
                              label: Text('Não'),
                              selected: answer == false,
                              onSelected: (isSelected) {
                                setState(() { _answers[index] = false; });
                              },
                              selectedColor: Colors.red[100],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitMChat,
        icon: Icon(Icons.check),
        label: Text('Finalizar Avaliação'),
      ),
    );
  }
}