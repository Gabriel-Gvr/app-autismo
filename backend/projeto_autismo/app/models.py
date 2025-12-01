from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy.types import JSON, Date
import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    role = db.Column(db.String(50), nullable=False)
    
    routines = db.relationship('Routine', backref='owner', lazy=True)
    entries = db.relationship('Entry', backref='owner', lazy=True)
    boards = db.relationship('Board', backref='owner', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Routine(db.Model):
    __tablename__ = 'routine'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    titulo = db.Column(db.String(200), nullable=False)
    lembrete = db.Column(db.Time, nullable=True) 
    steps = db.relationship('RoutineStep', backref='routine', lazy=True, cascade="all, delete-orphan")

class RoutineStep(db.Model):
    __tablename__ = 'routine_step'
    id = db.Column(db.Integer, primary_key=True)
    routine_id = db.Column(db.Integer, db.ForeignKey('routine.id'), nullable=False)
    descricao = db.Column(db.String(300), nullable=False)
    duracao = db.Column(db.Integer, nullable=True) 
    icone = db.Column(db.String(50), nullable=True) 
    feito = db.Column(db.Boolean, default=False)

class Entry(db.Model):
    __tablename__ = 'entry'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    tipo = db.Column(db.String(50), nullable=False) 
    texto = db.Column(db.Text, nullable=True)
    midia_url = db.Column(db.String(500), nullable=True)
    tags = db.Column(db.String(200), nullable=True)
    ts = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    tipo = db.Column(db.String(50), nullable=False) 
    
    data = db.Column(db.Date, nullable=True) 
    
    texto = db.Column(db.Text, nullable=True)
    
    details = db.Column(JSON, nullable=True) 

    midia_url = db.Column(db.String(500), nullable=True)
    tags = db.Column(db.String(200), nullable=True)
    ts = db.Column(db.DateTime, default=datetime.datetime.utcnow) 

class Board(db.Model):
    __tablename__ = 'board'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    nome = db.Column(db.String(100), nullable=False)
    items = db.relationship('BoardItem', backref='board', lazy=True, cascade="all, delete-orphan")

class BoardItem(db.Model):
    __tablename__ = 'board_item'
    id = db.Column(db.Integer, primary_key=True)
    board_id = db.Column(db.Integer, db.ForeignKey('board.id'), nullable=False)
    texto = db.Column(db.String(100), nullable=False)
    img_url = db.Column(db.String(500), nullable=True)
    audio_url = db.Column(db.String(500), nullable=True) 

class Share(db.Model):
    __tablename__ = 'share'
    id = db.Column(db.Integer, primary_key=True)
    owner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    viewer_email = db.Column(db.String(120), nullable=False) 
    escopo = db.Column(db.String(100), nullable=False) 
    expira_em = db.Column(db.DateTime, nullable=True)

class Assessment(db.Model):
   
    __tablename__ = 'assessment'
    id = db.Column(db.Integer, primary_key=True)
    
    aplicador_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    status = db.Column(db.String(50), default='rascunho')
    
    paciente_json = db.Column(JSON, nullable=True)
    responsaveis_json = db.Column(JSON, nullable=True)
    
    secoes_json = db.Column(JSON, nullable=True) 
    
    ts = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    
    mchat = db.relationship('AssessmentMchat', backref='assessment', uselist=False, lazy=True, cascade="all, delete-orphan")

class AssessmentMchat(db.Model):
   
    __tablename__ = 'assessment_mchat'
    id = db.Column(db.Integer, primary_key=True)
    
    assessment_id = db.Column(db.Integer, db.ForeignKey('assessment.id'), unique=True, nullable=False)
    
    respostas_json = db.Column(JSON, nullable=False) 
    
    score_total = db.Column(db.Integer)
    itens_criticos_json = db.Column(JSON)
    classificacao = db.Column(db.String(50))
    
    ts = db.Column(db.DateTime, default=datetime.datetime.utcnow)