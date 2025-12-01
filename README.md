# App de Rotina e Comunicação para Autismo 🧩

Aplicativo desenvolvido para apoiar a rotina, comunicação (CAA) e acompanhamento diário de pessoas autistas, com interface dedicada para responsáveis e psicólogos.

## 🚀 Funcionalidades

### 📱 Módulo do Responsável
- **Rotinas:** Criação de rotinas visuais com timer e checklist.
- **Diário:** Registro diário de humor, sono, alimentação e crises.
- **CAA (Comunicação Alternativa):** Pranchas de comunicação com texto-para-fala (TTS) e ícones dinâmicos.
- **Relatórios:** Visualização gráfica do histórico semanal.
- **Modo Crise:** Acesso rápido a instruções de acalmamento e contatos de emergência (funciona offline).

### 🧑‍⚕️ Módulo do Psicólogo
- **Anamnese:** Formulário digital completo com 8 etapas.
- **M-CHAT:** Aplicação e cálculo automático de risco de autismo.
- **Dashboard:** Visualização de pacientes e relatórios compartilhados.

## 🛠️ Tecnologias Utilizadas

- **Frontend:** Flutter (Mobile)
- **Backend:** Python (Flask)
- **Banco de Dados:** SQLite (SQLAlchemy)
- **Autenticação:** JWT (JSON Web Tokens)

## 📦 Como Rodar

### Backend
1. Entre na pasta `backend`.
2. Instale as dependências: `pip install -r requirements.txt`.
3. Execute: `python run.py`.

### Mobile
1. Entre na pasta `frontend`.
2. Instale as dependências: `flutter pub get`.
3. Configure o IP da API em `lib/utils/constants.dart`.
4. Execute: `flutter run`.