from methods.UserModel import *

users = [
    User(1, 'user1', 'aaa'),
    User(2, 'user2', 'abcxyz')
]
username_table = {u.username: u for u in users}
userid_table = {u.id: u for u in users}


def config():
    from datetime import timedelta
    return {'APPLICATION_ROOT': '/',
            'DEBUG': True,
            'ENV': 'production',
            'EXPLAIN_TEMPLATE_LOADING': False,
            'JSONIFY_MIMETYPE': 'application/json',
            'JSONIFY_PRETTYPRINT_REGULAR': True,
            'JSON_AS_ASCII': True,
            'JSON_SORT_KEYS': True,
            'JWT_AUTH_HEADER_PREFIX': 'Bearer',
            'JWT_EXPIRATION_DELTA': timedelta(seconds=86400),
            'MAX_CONTENT_LENGTH': None,
            'MAX_COOKIE_SIZE': 4093,
            'PERMANENT_SESSION_LIFETIME': timedelta(days=31),
            'PREFERRED_URL_SCHEME': 'http',
            'PRESERVE_CONTEXT_ON_EXCEPTION': None,
            'PROPAGATE_EXCEPTIONS': None,
            'SECRET_KEY': 'super-secret',
            'SEND_FILE_MAX_AGE_DEFAULT': timedelta(seconds=43200),
            'SERVER_NAME': None,
            'SESSION_COOKIE_DOMAIN': None,
            'SESSION_COOKIE_HTTPONLY': True,
            'SESSION_COOKIE_NAME': 'session',
            'SESSION_COOKIE_PATH': None,
            'SESSION_COOKIE_SAMESITE': None,
            'SESSION_COOKIE_SECURE': False,
            'SESSION_REFRESH_EACH_REQUEST': True,
            'TEMPLATES_AUTO_RELOAD': None,
            'TESTING': False,
            'TRAP_BAD_REQUEST_ERRORS': None,
            'TRAP_HTTP_EXCEPTIONS': False,
            'USE_X_SENDFILE': False}
