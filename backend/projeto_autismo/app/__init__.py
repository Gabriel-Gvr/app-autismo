from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from .models import db
import os

def create_app():
    app = Flask(__name__)
    CORS(app)
    
    base_dir = os.path.abspath(os.path.dirname(__file__))
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(base_dir, 'app.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    app.config['JWT_SECRET_KEY'] = os.getenv('SECRET_KEY', 'devkey')
    jwt = JWTManager(app)

    db.init_app(app)

    with app.app_context():
        from . import routes
        
        db.create_all()

    return app