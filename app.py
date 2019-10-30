from flask import Blueprint
from flask import Flask
from flask_jwt import JWT
from flask_restful import Api
from pony.orm.core import Database

from config import config, userid_table, username_table
from methods.Authentication import ConnectionAuth
from sql.Connection import DbAuth

app = Flask(__name__)
app.config = config()
# blueprint api
api_bp = Blueprint('api', __name__)
api = Api(api_bp)
app.register_blueprint(api_bp, url_prefix='/api')

# Authentication to server
auth = ConnectionAuth(username_table, userid_table)
jwt = JWT(app, auth.authenticate, auth.identity)

# Authentication/connection config.yaml to database
# import cryptography
db = Database()
dbAuth = dict(DbAuth('config.yaml').load())
db.bind(**dbAuth['mysql'])



