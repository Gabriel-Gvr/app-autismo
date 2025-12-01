import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/psychologist_service.dart';
import 'package:intl/intl.dart';
import 'package:app_autismo/screens/mchat_screen.dart';

class AnamneseFormScreen extends StatefulWidget {
  const AnamneseFormScreen({Key? key}) : super(key: key);

  @override
  _AnamneseFormScreenState createState() => _AnamneseFormScreenState();
}

class _AnamneseFormScreenState extends State<AnamneseFormScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final Map<String, TextEditingController> _controllers = {
    'data_avaliacao': TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now())),
    'aplicador': TextEditingController(),
    'paciente_nome': TextEditingController(),
    'paciente_nascimento': TextEditingController(),
    'responsaveis': TextEditingController(),
    'cidade': TextEditingController(),
    'celular': TextEditingController(),
    'cuidadores': TextEditingController(),
    'composicao_familiar': TextEditingController(),
    'pessoas_autorizadas': TextEditingController(),
    'medico_responsavel': TextEditingController(),
    'medico_assistente': TextEditingController(),
    'diagnostico': TextEditingController(),
    'medicamentos': TextEditingController(),
    'alergias': TextEditingController(),
    'audicao_exame': TextEditingController(),
    'audicao_percepcao': TextEditingController(),
    'otites': TextEditingController(),
    'gestacao_planejada': TextEditingController(),
    'gestacao_intercorrencias': TextEditingController(),
    'gestacao_semanas': TextEditingController(),
    'parto_tipo': TextEditingController(),
    'apgar': TextEditingController(),
    'peso': TextEditingController(),
    'altura': TextEditingController(),
    'parto_intercorrencias': TextEditingController(),
    'amamentacao': TextEditingController(),
    'dnpm_cervical': TextEditingController(),
    'dnpm_sentar': TextEditingController(),
    'dnpm_engatinhar': TextEditingController(),
    'dnpm_andar': TextEditingController(),
    'dnpm_palavras': TextEditingController(),
    'dnpm_verbal': TextEditingController(),
    'dnpm_motor_amplo': TextEditingController(),
    'dnpm_motor_fino': TextEditingController(),
    'escola_frequenta': TextEditingController(text: 'Sim'),
    'escola_qual': TextEditingController(),
    'escola_turno': TextEditingController(),
    'escola_ano': TextEditingController(),
    'escola_professora': TextEditingController(),
    'escola_comportamento': TextEditingController(),
    'avd_banheiro': TextEditingController(),
    'avd_banho': TextEditingController(),
    'avd_dentes': TextEditingController(),
    'avd_vestir': TextEditingController(),
    'avd_maos': TextEditingController(),
    'avd_alimentacao': TextEditingController(),
    'avd_degluticao': TextEditingController(),
    'avd_restricoes': TextEditingController(),
    'avd_habitos': TextEditingController(),
    'avd_sono': TextEditingController(),
    'avd_chupeta': TextEditingController(),
    'avd_mamadeira': TextEditingController(),
    'sensorial_tatil': TextEditingController(),
    'sensorial_auditiva': TextEditingController(),
    'sensorial_olfativa': TextEditingController(),
    'sensorial_visual': TextEditingController(),
    'brincar_preferencias': TextEditingController(),
    'medos': TextEditingController(),
    'socializacao': TextEditingController(),
    'queixas': TextEditingController(),
    'comportamentos_inadequados': TextEditingController(),
    'observacoes': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> payload = {
      "aplicador": _controllers['aplicador']!.text,
      "paciente": {
        "name": _controllers['paciente_nome']!.text,
        "nascimento": _controllers['paciente_nascimento']!.text
      },
      "responsaveis": _controllers['responsaveis']!.text.split(','),
      "Identificacao": {
        "data_avaliacao": _controllers['data_avaliacao']!.text,
        "cidade": _controllers['cidade']!.text,
        "celular": _controllers['celular']!.text,
        "cuidadores": _controllers['cuidadores']!.text,
        "composicao_familiar": _controllers['composicao_familiar']!.text,
        "pessoas_autorizadas": _controllers['pessoas_autorizadas']!.text,
      },
      "medico": {
        "responsavel": _controllers['medico_responsavel']!.text,
        "assistente": _controllers['medico_assistente']!.text,
        "diagnostico": _controllers['diagnostico']!.text,
        "medicamentos": _controllers['medicamentos']!.text,
        "alergias": _controllers['alergias']!.text,
        "audicao_exame": _controllers['audicao_exame']!.text,
        "audicao_percepcao": _controllers['audicao_percepcao']!.text,
        "otites": _controllers['otites']!.text,
      },
      "gestacao_parto_puerperio": {
        "planejada": _controllers['gestacao_planejada']!.text,
        "intercorrencias": _controllers['gestacao_intercorrencias']!.text,
        "semanas": _controllers['gestacao_semanas']!.text,
        "parto": _controllers['parto_tipo']!.text,
        "apgar": _controllers['apgar']!.text,
        "peso": _controllers['peso']!.text,
        "altura": _controllers['altura']!.text,
        "pos_intercorrencias": _controllers['parto_intercorrencias']!.text,
        "amamentacao": _controllers['amamentacao']!.text,
      },
      "dnpm": {
        "controle_cervical": _controllers['dnpm_cervical']!.text,
        "sentar": _controllers['dnpm_sentar']!.text,
        "engatinhar": _controllers['dnpm_engatinhar']!.text,
        "andar": _controllers['dnpm_andar']!.text,
        "primeiras_palavras": _controllers['dnpm_palavras']!.text,
        "comportamento_verbal": _controllers['dnpm_verbal']!.text,
        "motor_amplo": _controllers['dnpm_motor_amplo']!.text,
        "motor_fino": _controllers['dnpm_motor_fino']!.text,
      },
      "escola": {
        "frequenta": _controllers['escola_frequenta']!.text.toLowerCase() == 'sim',
        "qual": _controllers['escola_qual']!.text,
        "turno": _controllers['escola_turno']!.text,
        "ano": _controllers['escola_ano']!.text,
        "professora": _controllers['escola_professora']!.text,
        "comportamento": _controllers['escola_comportamento']!.text,
      },
      "avd": {
        "banheiro": _controllers['avd_banheiro']!.text,
        "banho": _controllers['avd_banho']!.text,
        "dentes": _controllers['avd_dentes']!.text,
        "vestir": _controllers['avd_vestir']!.text,
        "maos": _controllers['avd_maos']!.text,
        "alimentacao": _controllers['avd_alimentacao']!.text,
        "degluticao": _controllers['avd_degluticao']!.text,
        "restricoes": _controllers['avd_restricoes']!.text,
        "habitos": _controllers['avd_habitos']!.text,
        "sono": _controllers['avd_sono']!.text,
        "chupeta": _controllers['avd_chupeta']!.text,
        "mamadeira": _controllers['avd_mamadeira']!.text,
      },
      "sensorial": {
        "tatil": _controllers['sensorial_tatil']!.text,
        "auditiva": _controllers['sensorial_auditiva']!.text,
        "olfativa": _controllers['sensorial_olfativa']!.text,
        "visual": _controllers['sensorial_visual']!.text,
      },
      "brincar_preferencias": _controllers['brincar_preferencias']!.text,
      "medos": _controllers['medos']!.text,
      "socializacao": _controllers['socializacao']!.text,
      "queixas": _controllers['queixas']!.text,
      "comportamentos_Inadequados": _controllers['comportamentos_inadequados']!.text,
      "observacoes": _controllers['observacoes']!.text
    };

    final psychService = Provider.of<PsychologistService>(context, listen: false);
    final newAssessmentId = await psychService.createAssessment(payload);

    setState(() {
      _isLoading = false;
    });

    if (newAssessmentId != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MChatScreen(assessmentId: newAssessmentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar Anamnese.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Anamnese'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < _buildSteps().length - 1) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _submitForm();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: _buildSteps(),
            ),
    );
  }

  Widget _buildTextField(String label, String controllerKey, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[controllerKey],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: (keyboardType == TextInputType.multiline) ? 3 : 1,
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('1. Identificação'),
        content: Column(
          children: [
            _buildTextField('Data da Avaliação (AAAA-MM-DD)', 'data_avaliacao'),
            _buildTextField('Aplicador', 'aplicador'),
            _buildTextField('Nome do Paciente', 'paciente_nome'),
            _buildTextField('Data de Nascimento (AAAA-MM-DD)', 'paciente_nascimento'),
            _buildTextField('Responsáveis (separados por vírgula)', 'responsaveis'),
            _buildTextField('Cidade', 'cidade'),
            _buildTextField('Celular', 'celular', keyboardType: TextInputType.phone),
            _buildTextField('Cuidadores', 'cuidadores', keyboardType: TextInputType.multiline),
            _buildTextField('Composição Familiar', 'composicao_familiar', keyboardType: TextInputType.multiline),
            _buildTextField('Pessoas Autorizadas a Buscar', 'pessoas_autorizadas'),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('2. Dados Médicos'),
        content: Column(
          children: [
            _buildTextField('Médico Responsável', 'medico_responsavel'),
            _buildTextField('Médico Assistente', 'medico_assistente'),
            _buildTextField('Diagnóstico Médico', 'diagnostico'),
            _buildTextField('Medicamentos', 'medicamentos', keyboardType: TextInputType.multiline),
            _buildTextField('Alergias', 'alergias'),
            _buildTextField('Exame de Audição Recente', 'audicao_exame'),
            _buildTextField('Percepção dos Pais (Audição)', 'audicao_percepcao'),
            _buildTextField('Histórico de Otites', 'otites'),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('3. Gestação e Parto'),
        content: Column(
          children: [
            _buildTextField('Gestação Planejada?', 'gestacao_planejada'),
            _buildTextField('Intercorrências na Gestação', 'gestacao_intercorrencias'),
            _buildTextField('Semanas (Nascimento)', 'gestacao_semanas', keyboardType: TextInputType.number),
            _buildTextField('Tipo de Parto', 'parto_tipo'),
            _buildTextField('Apgar', 'apgar'),
            _buildTextField('Peso (Nascimento)', 'peso'),
            _buildTextField('Altura (Nascimento)', 'altura'),
            _buildTextField('Intercorrências (Parto/Pós)', 'parto_intercorrencias'),
            _buildTextField('Amamentação', 'amamentacao'),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: Text('4. DNPM'),
        content: Column(
          children: [
            _buildTextField('Controle Cervical (Idade)', 'dnpm_cervical'),
            _buildTextField('Sentar sem Apoio (Idade)', 'dnpm_sentar'),
            _buildTextField('Engatinhar (Idade)', 'dnpm_engatinhar'),
            _buildTextField('Andar (Idade)', 'dnpm_andar'),
            _buildTextField('Primeiras Palavras (Idade)', 'dnpm_palavras'),
            _buildTextField('Comportamento Verbal', 'dnpm_verbal'),
            _buildTextField('Motor Amplo', 'dnpm_motor_amplo'),
            _buildTextField('Motor Fino', 'dnpm_motor_fino'),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: Text('5. Escola'),
        content: Column(
          children: [
            _buildTextField('Frequenta Escola? (Sim/Não)', 'escola_frequenta'),
            _buildTextField('Qual Escola?', 'escola_qual'),
            _buildTextField('Turno', 'escola_turno'),
            _buildTextField('Ano', 'escola_ano'),
            _buildTextField('Nome da Professora', 'escola_professora'),
            _buildTextField('Comportamento na Escola', 'escola_comportamento', keyboardType: TextInputType.multiline),
          ],
        ),
        isActive: _currentStep >= 4,
      ),
      Step(
        title: Text('6. Autocuidado (AVD)'),
        content: Column(
          children: [
            _buildTextField('Banheiro / Controle Esfíncteres', 'avd_banheiro'),
            _buildTextField('Banho', 'avd_banho'),
            _buildTextField('Escovar os Dentes', 'avd_dentes'),
            _buildTextField('Vestir-se', 'avd_vestir'),
            _buildTextField('Lavar as Mãos', 'avd_maos'),
            _buildTextField('Alimentação', 'avd_alimentacao'),
            _buildTextField('Dificuldade Deglutição', 'avd_degluticao'),
            _buildTextField('Restrições Alimentares', 'avd_restricoes'),
            _buildTextField('Hábitos Alimentares', 'avd_habitos'),
            _buildTextField('Sono', 'avd_sono'),
            _buildTextField('Usa Chupeta?', 'avd_chupeta'),
            _buildTextField('Usa Mamadeira?', 'avd_mamadeira'),
          ],
        ),
        isActive: _currentStep >= 5,
      ),
      Step(
        title: Text('7. Sensorial'),
        content: Column(
          children: [
            _buildTextField('Tátil', 'sensorial_tatil', keyboardType: TextInputType.multiline),
            _buildTextField('Auditiva', 'sensorial_auditiva', keyboardType: TextInputType.multiline),
            _buildTextField('Olfativa', 'sensorial_olfativa', keyboardType: TextInputType.multiline),
            _buildTextField('Visual', 'sensorial_visual', keyboardType: TextInputType.multiline),
          ],
        ),
        isActive: _currentStep >= 6,
      ),
      Step(
        title: Text('8. Observações Finais'),
        content: Column(
          children: [
            _buildTextField('Brincar / Preferências', 'brincar_preferencias', keyboardType: TextInputType.multiline),
            _buildTextField('Medos', 'medos', keyboardType: TextInputType.multiline),
            _buildTextField('Socialização', 'socializacao', keyboardType: TextInputType.multiline),
            _buildTextField('Queixas', 'queixas', keyboardType: TextInputType.multiline),
            _buildTextField('Comportamentos Inadequados', 'comportamentos_inadequados', keyboardType: TextInputType.multiline),
            _buildTextField('Observações Gerais', 'observacoes', keyboardType: TextInputType.multiline),
          ],
        ),
        isActive: _currentStep >= 7,
      ),
    ];
  }
}