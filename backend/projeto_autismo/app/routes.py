from datetime import date, timedelta
from collections import Counter
from sqlalchemy import func, cast, Date
from .models import (
    db, User, Routine, RoutineStep, Entry, Board, BoardItem, Share,
    Assessment, AssessmentMchat 
)
from flask import request, jsonify, current_app as app
from flask_jwt_extended import (
    create_access_token, 
    create_refresh_token,
    jwt_required,
    get_jwt_identity
)
import datetime

def _get_report_data_for_user(user_id, date_from, date_to):
    entries = Entry.query.filter(
        Entry.user_id == user_id,
        Entry.tipo == 'diario',
        Entry.data.between(date_from, date_to),
        Entry.details != None
    ).all()

    humor_counts = Counter()
    sono_counts = Counter()
    alimentacao_counts = Counter()
    crise_counts = Counter()

    for entry in entries:
        if not entry.details:
            continue
        
        if entry.details.get('humor'):
            humor_counts[entry.details['humor']] += 1
        if entry.details.get('sono'):
            sono_counts[entry.details['sono']] += 1
        if entry.details.get('alimentacao'):
            alimentacao_counts[entry.details['alimentacao']] += 1
        if entry.details.get('crise'):
            crise_counts[entry.details['crise']] += 1

    return {
        "humor": dict(humor_counts),
        "sono": dict(sono_counts),
        "alimentacao": dict(alimentacao_counts),
        "crise": dict(crise_counts)
    }

def _calculate_mchat_score(respostas):
    if not isinstance(respostas, dict):
        return 0, [], "erro" 

    PONTUA_SIM = {11, 18, 20, 22}
    PONTUA_NAO = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 19, 21, 23}
    ITENS_CRITICOS = {2, 7, 9, 13, 14, 15}

    score_total = 0
    itens_criticos_marcados = []

    for i in range(1, 24):
        item_str = str(i)
        resposta = respostas.get(item_str, "").lower() 
        
        item_pontuou = False
        
        if i in PONTUA_SIM and resposta == "sim":
            item_pontuou = True
        elif i in PONTUA_NAO and resposta == "nao":
            item_pontuou = True
            
        if item_pontuou:
            score_total += 1
            if i in ITENS_CRITICOS:
                itens_criticos_marcados.append(item_str)

    score_critico = len(itens_criticos_marcados)
    classificacao = "baixo_risco"
    
    if score_total > 3 or score_critico >= 2:
        classificacao = "risco"
    
    return score_total, itens_criticos_marcados, classificacao

@app.route('/')
def index():
    return jsonify({"message": "API no ar"})

@app.route('/auth/signup', methods=['POST'])
def signup():
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'responsavel') 
    
    allowed_roles = ['autista', 'responsavel', 'profissional', 'admin', 'psicologo']
    if role not in allowed_roles:
        return jsonify({"error": f"Role '{role}' inválido."}), 400

    if not email or not password:
        return jsonify({"error": "Email e senha são obrigatórios"}), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({"error": "Email já cadastrado"}), 400

    new_user = User(email=email, role=role) 
    new_user.set_password(password)
    
    db.session.add(new_user)
    db.session.commit()
    
    access_token = create_access_token(identity=str(new_user.id))
    refresh_token = create_refresh_token(identity=str(new_user.id))

    return jsonify({
        "message": "Usuário criado com sucesso",
        "access_token": access_token,
        "refresh_token": refresh_token
    }), 201

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()

    if user and user.check_password(password):
        access_token = create_access_token(identity=str(user.id))
        refresh_token = create_refresh_token(identity=str(user.id))
        
        return jsonify({
            "access_token": access_token,
            "refresh_token": refresh_token,
            "role": user.role
        }), 200
    
    return jsonify({"error": "Credenciais inválidas"}), 401

@app.route('/routines', methods=['POST'])
@jwt_required()
def create_routine():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    data = request.get_json()
    titulo = data.get('titulo')
    if not titulo:
        return jsonify({"error": "O título é obrigatório"}), 400

    lembrete_time = None
    if data.get('lembrete'):
        try:
            lembrete_time = datetime.time.fromisoformat(data.get('lembrete'))
        except ValueError:
            return jsonify({"error": "Formato de lembrete inválido. Use HH:MM"}), 400

    new_routine = Routine(
        user_id=current_user_id,
        titulo=titulo,
        lembrete=lembrete_time
    )
    db.session.add(new_routine)
    
    steps_data = data.get('steps', [])
    for step_info in steps_data:
        new_step = RoutineStep(
            routine=new_routine,
            descricao=step_info.get('descricao'),
            duracao=step_info.get('duracao_segundos'),
            icone=step_info.get('icone')
        )
        db.session.add(new_step)

    try:
        db.session.commit()
        return jsonify({"message": "Rotina criada com sucesso", "id": new_routine.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/routines', methods=['GET'])
@jwt_required()
def get_routines():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    routines = Routine.query.filter_by(user_id=current_user_id).all()
    
    output = []
    for routine in routines:
        routine_data = {
            "id": routine.id,
            "titulo": routine.titulo,
            "lembrete": routine.lembrete.strftime('%H:%M') if routine.lembrete else None,
            "steps": []
        }
        for step in routine.steps:
            routine_data["steps"].append({
                "id": step.id,
                "descricao": step.descricao,
                "duracao": step.duracao,
                "icone": step.icone,
                "feito": step.feito
            })
        output.append(routine_data)

    return jsonify(output)

@app.route('/routines/<int:routine_id>', methods=['PUT'])
@jwt_required()
def update_routine(routine_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    routine = Routine.query.get_or_404(routine_id)

    if routine.user_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado"}), 403

    data = request.get_json()
    
    if 'titulo' in data:
        routine.titulo = data['titulo']
        
    if 'lembrete' in data:
        try:
            routine.lembrete = datetime.time.fromisoformat(data.get('lembrete')) if data.get('lembrete') else None
        except ValueError:
            return jsonify({"error": "Formato de lembrete inválido. Use HH:MM"}), 400

    db.session.commit()
    return jsonify({"message": "Rotina atualizada com sucesso"})

@app.route('/routines/<int:routine_id>', methods=['DELETE'])
@jwt_required()
def delete_routine(routine_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    routine = Routine.query.get_or_404(routine_id)

    if routine.user_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado"}), 403

    db.session.delete(routine)
    db.session.commit()
    
    return jsonify({"message": "Rotina excluída com sucesso"})

@app.route('/routines/<int:routine_id>/steps', methods=['POST'])
@jwt_required()
def add_step_to_routine(routine_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    routine = Routine.query.get_or_404(routine_id)

    if routine.user_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado"}), 403

    data = request.get_json()
    if not data or not data.get('descricao'):
        return jsonify({"error": "Descrição do passo é obrigatória"}), 400

    new_step = RoutineStep(
        routine_id=routine.id,
        descricao=data.get('descricao'),
        duracao=data.get('duracao'),
        icone=data.get('icone')
    )
    
    db.session.add(new_step)
    db.session.commit()
    
    return jsonify({"message": "Passo adicionado com sucesso", "step_id": new_step.id}), 201

@app.route('/routines/<int:routine_id>/steps/<int:step_id>/check', methods=['PATCH'])
@jwt_required()
def check_routine_step(routine_id, step_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    step = RoutineStep.query.get_or_404(step_id)

    if step.routine_id != routine_id or step.routine.user_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado"}), 403

    data = request.get_json()
    if 'feito' not in data or not isinstance(data.get('feito'), bool):
        return jsonify({"error": "Payload inválido. Esperado {'feito': true/false}"}), 400

    step.feito = data.get('feito')
    db.session.commit()
    
    return jsonify({"message": f"Passo {step.id} marcado como {step.feito}"})

@app.route('/entries', methods=['POST'])
@jwt_required()
def create_entry():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    data = request.get_json()
    tipo = data.get('tipo')
    if not tipo:
        return jsonify({"error": "O campo 'tipo' é obrigatório"}), 400

    new_entry = Entry(user_id=current_user_id, tipo=tipo)

    if tipo == 'diario':
        new_entry.texto = data.get('observacao')
        
        if data.get('data'):
            try:
                new_entry.data = date.fromisoformat(data.get('data'))
            except ValueError:
                return jsonify({"error": "Formato de data inválido. Use AAAA-MM-DD"}), 400
        
        new_entry.details = {
            "humor": data.get('humor'),
            "sono": data.get('sono'),
            "alimentacao": data.get('alimentacao'),
            "crise": data.get('crise')
        }
    else:
        new_entry.texto = data.get('texto')
        new_entry.midia_url = data.get('midia_url')
        new_entry.tags = data.get('tags')
        new_entry.data = date.today()

    db.session.add(new_entry)
    db.session.commit()
    
    return jsonify({"message": "Entrada criada com sucesso", "id": new_entry.id}), 201

@app.route('/entries', methods=['GET'])
@jwt_required()
def get_entries():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
    
    filter_tipo = request.args.get('tipo')
    filter_from = request.args.get('from')
    filter_to = request.args.get('to')

    query = Entry.query.filter_by(user_id=current_user_id)

    if filter_tipo:
        query = query.filter_by(tipo=filter_tipo)
    
    if filter_from:
        try:
            date_from = date.fromisoformat(filter_from)
            query = query.filter(db.or_(Entry.data >= date_from, Entry.ts >= date_from))
        except ValueError:
            return jsonify({"error": "Formato de data 'from' inválido. Use AAAA-MM-DD"}), 400
            
    if filter_to:
        try:
            date_to = date.fromisoformat(filter_to)
            query = query.filter(db.or_(Entry.data <= date_to, Entry.ts <= date_to))
        except ValueError:
            return jsonify({"error": "Formato de data 'to' inválido. Use AAAA-MM-DD"}), 400

    entries = query.order_by(Entry.ts.desc()).all()

    output = []
    for entry in entries:
        output.append({
            "id": entry.id,
            "tipo": entry.tipo,
            "data": entry.data.isoformat() if entry.data else None,
            "texto": entry.texto,
            "details": entry.details,
            "midia_url": entry.midia_url,
            "tags": entry.tags,
            "criado_em": entry.ts.isoformat()
        })

    return jsonify(output)

@app.route('/boards', methods=['GET'])
@jwt_required()
def get_boards():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    boards = Board.query.filter_by(user_id=current_user_id).all()
    
    output = []
    for board in boards:
        board_data = {
            "id": board.id,
            "nome": board.nome,
            "items": []
        }
        for item in board.items:
            board_data["items"].append({
                "id": item.id,
                "texto": item.texto,
                "img_url": item.img_url,
                "audio_url": item.audio_url 
            })
        output.append(board_data)

    return jsonify(output)

@app.route('/boards', methods=['POST'])
@jwt_required()
def create_board():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    data = request.get_json()
    nome = data.get('nome')
    if not nome:
        return jsonify({"error": "O campo 'nome' da prancha é obrigatório"}), 400

    new_board = Board(
        user_id=current_user_id,
        nome=nome
    )
    
    db.session.add(new_board)
    db.session.commit()
    
    return jsonify({"message": "Prancha criada com sucesso", "id": new_board.id}), 201

@app.route('/boards/<int:board_id>/items', methods=['POST'])
@jwt_required()
def add_item_to_board(board_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    board = Board.query.get_or_404(board_id)
    if board.user_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado a esta prancha"}), 403

    data = request.get_json()
    texto = data.get('texto')
    
    if not texto:
        return jsonify({"error": "O campo 'texto' do item é obrigatório"}), 400

    new_item = BoardItem(
        board_id=board.id,
        texto=texto,
        img_url=data.get('img_url'),
        audio_url=data.get('audio_frase') 
    )
    
    db.session.add(new_item)
    db.session.commit()
    
    return jsonify({"message": "Item adicionado à prancha com sucesso", "item_id": new_item.id}), 201

@app.route('/reports/weekly', methods=['GET'])
@jwt_required()
def get_weekly_report():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
    
    today = date.today()
    default_from = today - timedelta(days=7)
    
    filter_from_str = request.args.get('from', default_from.isoformat())
    filter_to_str = request.args.get('to', today.isoformat())

    try:
        filter_from = date.fromisoformat(filter_from_str)
        filter_to = date.fromisoformat(filter_to_str)
    except ValueError:
        return jsonify({"error": "Formato de data inválido. Use AAAA-MM-DD"}), 400

    try:
        aggregated_data = _get_report_data_for_user(current_user_id, filter_from, filter_to)
        
        report = {
            "periodo": {
                "de": filter_from.isoformat(),
                "ate": filter_to.isoformat()
            },
            "agregados": aggregated_data
        }
        return jsonify(report)
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Falha ao agregar relatório", "details": str(e)}), 500

@app.route('/reports/export', methods=['POST'])
@jwt_required()
def export_report():
    return jsonify({
        "message": "Solicitação de exportação recebida.",
        "status": "pendente",
        "download_link_mock": "/api/exports/report-xyz-123.pdf" 
    }), 202 

@app.route('/shares', methods=['POST'])
@jwt_required()
def create_share():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    data = request.get_json()
    viewer_email = data.get('viewer_email')
    escopo = data.get('escopo', 'relatorios')  
    
    if not viewer_email:
        return jsonify({"error": "O 'viewer_email' (e-mail do profissional) é obrigatório"}), 400

    existing_share = Share.query.filter_by(
        owner_id=current_user_id, 
        viewer_email=viewer_email
    ).first()
    
    if existing_share:
        return jsonify({"error": "Já existe um compartilhamento ativo para este e-mail"}), 409

    expira_em_date = None
    if data.get('expira_em'):
        try:
            expira_em_date = date.fromisoformat(data.get('expira_em'))
        except ValueError:
            return jsonify({"error": "Formato de data 'expira_em' inválido. Use AAAA-MM-DD"}), 400

    new_share = Share(
        owner_id=current_user_id,
        viewer_email=viewer_email,
        escopo=escopo,
        expira_em=expira_em_date
    )
    
    db.session.add(new_share)
    db.session.commit()
    
    return jsonify({"message": "Compartilhamento criado com sucesso", "id": new_share.id}), 201

@app.route('/shares/<int:share_id>', methods=['DELETE'])
@jwt_required()
def delete_share(share_id):
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    share = Share.query.get_or_404(share_id)
    
    if share.owner_id != current_user_id:
        return jsonify({"error": "Acesso não autorizado"}), 403
        
    db.session.delete(share)
    db.session.commit()
    
    return jsonify({"message": "Compartilhamento removido com sucesso"})

@app.route('/shares', methods=['GET'])
@jwt_required()
def get_shares():
    try:
        current_user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401

    try:
        shares = Share.query.filter_by(owner_id=current_user_id).all()
        
        output = []
        for share in shares:
            output.append({
                "id": share.id,
                "viewer_email": share.viewer_email,
                "escopo": share.escopo,
                "expira_em": share.expira_em.isoformat() if share.expira_em else None
            })
            
        return jsonify(output)
        
    except Exception as e:
        return jsonify({"error": "Erro ao consultar compartilhamentos", "details": str(e)}), 500

def check_role(role_name):
    try:
        user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return False, jsonify({"error": "Token de usuário inválido"}), 401

    user = User.query.get(user_id)
    
    if not user or user.role != role_name:
        return False, jsonify({"error": f"Acesso restrito a usuários com role: '{role_name}'"}), 403
    
    return True, user, 200

@app.route('/psych/assessments', methods=['POST'])
@jwt_required()
def create_assessment():
    is_allowed, user_or_response, status = check_role('psicologo')
    if not is_allowed:
        return user_or_response, status
    
    psicologo_user = user_or_response 
    data = request.get_json()
    if not data:
        return jsonify({"error": "Payload JSON não encontrado"}), 400

    paciente_data = data.get('paciente')
    responsaveis_data = data.get('responsaveis')
    
    secoes_data = {
        "identificacao": data.get('Identificacao'),
        "medico": data.get('medico'),
        "gestacao_parto_puerperio": data.get('gestacao_parto_puerperio'),
        "dnpm": data.get('dnpm'),
        "escola": data.get('escola'),
        "avd": data.get('avd'),
        "sensorial": data.get('sensorial'),
        "brincar_preferencias": data.get('brincar_preferencias'),
        "medos": data.get('medos'),
        "socializacao": data.get('socializacao'),
        "queixas": data.get('queixas'),
        "comportamentos_inadequados": data.get('comportamentos_Inadequados'),
        "observacoes": data.get('observacoes')
    }

    new_assessment = Assessment(
        aplicador_id=psicologo_user.id,
        paciente_json=paciente_data,
        responsaveis_json=responsaveis_data,
        secoes_json=secoes_data,
        status=data.get('status', 'rascunho') 
    )
    
    db.session.add(new_assessment)
    db.session.commit()

    return jsonify({"message": "Avaliação (Anamnese) criada com sucesso", "id": new_assessment.id}), 201

@app.route('/psych/assessments/<int:assessment_id>', methods=['GET'])
@jwt_required()
def get_assessment(assessment_id):
    assessment = Assessment.query.get_or_404(assessment_id)
    try:
        user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
    
    user = User.query.get(user_id)

    if not user:
        return jsonify({"error": "Usuário do token não encontrado"}), 401
        
    if assessment.aplicador_id != user.id and user.role != 'admin':
        return jsonify({"error": "Acesso não autorizado"}), 403

    response_data = {
        "id": assessment.id,
        "aplicador_id": assessment.aplicador_id,
        "status": assessment.status,
        "ts": assessment.ts.isoformat(),
        "paciente": assessment.paciente_json,
        "responsaveis": assessment.responsaveis_json,
        **assessment.secoes_json 
    }

    return jsonify(response_data)

@app.route('/psych/assessments/<int:assessment_id>', methods=['PUT'])
@jwt_required()
def update_assessment(assessment_id):
    is_allowed, user_or_response, status = check_role('psicologo')
    if not is_allowed:
        return user_or_response, status
    
    assessment = Assessment.query.get_or_404(assessment_id)
    if assessment.aplicador_id != user_or_response.id:
        return jsonify({"error": "Você só pode editar avaliações que você criou"}), 403

    data = request.get_json()
    if not data:
        return jsonify({"error": "Payload JSON não encontrado"}), 400

    if 'paciente' in data:
        assessment.paciente_json = data.get('paciente')
    if 'responsaveis' in data:
        assessment.responsaveis_json = data.get('responsaveis')
    if 'status' in data:
        assessment.status = data.get('status')
        
    secoes_data = assessment.secoes_json or {}
    
    secoes_keys = [
        "Identificacao", "medico", "gestacao_parto_puerperio", "dnpm", 
        "escola", "avd", "sensorial", "brincar_preferencias", "medos", 
        "socializacao", "queixas", "comportamentos_Inadequados", "observacoes"
    ]
    
    for key in secoes_keys:
        if key in data:
            secoes_data[key.lower()] = data[key]

    assessment.secoes_json = secoes_data
    
    db.session.add(assessment)
    db.session.commit()
    
    return jsonify({"message": "Avaliação atualizada com sucesso"})

@app.route('/psych/assessments', methods=['GET'])
@jwt_required()
def get_all_assessments():
    is_allowed, user_or_response, status = check_role('psicologo')
    if not is_allowed:
        return user_or_response, status
    
    psicologo_user = user_or_response

    try:
        assessments = Assessment.query.filter_by(
            aplicador_id=psicologo_user.id
        ).order_by(Assessment.ts.desc()).all()
    except Exception as e:
        return jsonify({"error": "Erro ao consultar o banco", "details": str(e)}), 500

    output = []
    for assessment in assessments:
        patient_name = "Paciente não informado"
        if assessment.paciente_json and 'name' in assessment.paciente_json:
            patient_name = assessment.paciente_json['name']
            
        output.append({
            "id": assessment.id,
            "status": assessment.status,
            "data_criacao": assessment.ts.isoformat(),
            "paciente_nome": patient_name,
            "mchat_completo": (assessment.mchat is not None)
        })

    return jsonify(output)

@app.route('/psych/assessments/<int:assessment_id>/mchat', methods=['POST'])
@jwt_required()
def save_mchat_results(assessment_id):
    is_allowed, user_or_response, status = check_role('psicologo')
    if not is_allowed:
        return user_or_response, status
    
    assessment = Assessment.query.get_or_404(assessment_id)
    if assessment.aplicador_id != user_or_response.id:
        return jsonify({"error": "Você só pode adicionar M-CHAT às suas próprias avaliações"}), 403
        
    if assessment.mchat:
        return jsonify({"error": "Esta avaliação já possui um resultado M-CHAT"}), 409

    data = request.get_json()
    respostas = data.get('respostas')

    if not respostas or len(respostas) != 23:
        return jsonify({"error": "Payload inválido. 'respostas' deve conter 23 itens"}), 400

    score_total, itens_criticos, classificacao = _calculate_mchat_score(respostas)

    new_mchat = AssessmentMchat(
        assessment_id=assessment.id,
        respostas_json=respostas,
        score_total=score_total,
        itens_criticos_json=itens_criticos,
        classificacao=classificacao
    )
    
    db.session.add(new_mchat)
    db.session.commit()

    return jsonify({
        "message": "M-CHAT salvo e calculado com sucesso",
        "assessment_id": assessment.id,
        "score_total": score_total,
        "itens_criticos_marcados": itens_criticos,
        "classificacao": classificacao,
        "recomendacao": "Encaminhar para avaliação especializada e acompanhamento." if classificacao == "risco" else "Monitorar desenvolvimento."
    }), 201

@app.route('/psych/assessments/<int:assessment_id>/mchat', methods=['GET'])
@jwt_required()
def get_mchat_results(assessment_id):
    assessment = Assessment.query.get_or_404(assessment_id)
    
    try:
        user_id = int(get_jwt_identity())
    except (ValueError, TypeError):
        return jsonify({"error": "Token de usuário inválido"}), 401
        
    user = User.query.get(user_id)

    if not user:
        return jsonify({"error": "Usuário do token não encontrado"}), 401
    
    if assessment.aplicador_id != user.id and user.role != 'admin':
        return jsonify({"error": "Acesso não autorizado"}), 403
        
    mchat = assessment.mchat
    if not mchat:
        return jsonify({"error": "Nenhum resultado M-CHAT encontrado para esta avaliação"}), 404

    return jsonify({
        "assessment_id": mchat.assessment_id,
        "respostas": mchat.respostas_json,
        "score_total": mchat.score_total,
        "itens_criticos_marcados": mchat.itens_criticos_json,
        "classificacao": mchat.classificacao,
        "salvo_em": mchat.ts.isoformat()
    })

@app.route('/psych/shared_reports', methods=['GET'])
@jwt_required()
def get_shared_reports():
    is_allowed, psych_user, status = check_role('psicologo')
    if not is_allowed:
        return psych_user, status

    today = date.today()
    default_from = today - timedelta(days=7)
    filter_from = date.fromisoformat(request.args.get('from', default_from.isoformat()))
    filter_to = date.fromisoformat(request.args.get('to', today.isoformat()))

    try:
        shares = Share.query.filter_by(viewer_email=psych_user.email).all()
        
        if not shares:
            return jsonify([])

        final_reports = []
        
        for share in shares:
            owner = User.query.get(share.owner_id)
            if not owner:
                continue

            aggregated_data = _get_report_data_for_user(owner.id, filter_from, filter_to)

            if any(aggregated_data.values()):
                final_reports.append({
                    "paciente_id": owner.id,
                    "paciente_email": owner.email,
                    "periodo": {
                        "de": filter_from.isoformat(),
                        "ate": filter_to.isoformat()
                    },
                    "agregados": aggregated_data
                })
        
        return jsonify(final_reports)

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Falha ao buscar relatórios compartilhados", "details": str(e)}), 500