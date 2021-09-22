from contextlib import contextmanager

from sqlalchemy import MetaData, create_engine
from sqlalchemy.orm import scoped_session, sessionmaker

from methods.config import EngineUriMeta


class EngineUri(EngineUriMeta):
    """
    Object for defining the database variables.
    """

    def __init__(self):
        self.__dict__ = {k: v for k, v in vars(EngineUriMeta).items() if k[0] != '_'}

    def get(self) -> str:
        """
        SQLALCHEMY_DATABASE_URI
        :return: dialect+dialect://user:password@host:port/database
        :rtype: str
        """
        return self.serialize(**self.__dict__)

    @staticmethod
    def serialize(**kwargs) -> str:
        """
        Engine uri serializer
        :return: dialect+driver://user:password@host:port/database
        :rtype: str
        """
        if kwargs['dialect']:
            kwargs['dialect'] += "://"
        else:
            raise Exception(" dialect in database uri not set")
        if kwargs['driver']:
            kwargs['dialect'] = kwargs['dialect'][:-3]
            kwargs['driver'] = f"+{kwargs['driver']}://"
        if kwargs['user'] and kwargs['password']:
            kwargs['password'] = f":{kwargs['password']}"
        if kwargs['host']:
            kwargs['host'] = f"@{kwargs['host']}"
        if kwargs['port']:
            kwargs['port'] = f":{kwargs['port']}"
        if kwargs['database']:
            kwargs['database'] = f"/{kwargs['database']}"
        else:
            raise Exception("database in database uri not set")
        return ''.join([v for v in kwargs.values() if v])


class DB:
    def __init__(self, engine_uri=None):
        self.engine_uri = engine_uri
        self.engine = None
        self.Session = None
        self.MetaData = None
        self.reflected_tables = None

    def load_engine(self, engine_uri=None):
        if engine_uri:
            self.engine_uri = engine_uri
        self.engine = create_engine(self.engine_uri.get())
        self.Session = scoped_session(sessionmaker(bind=self.engine.connect()))
        self.MetaData = MetaData(bind=self.engine)

    def session(self):
        return session_scope(self.Session())


@contextmanager
def session_scope(session):
    """
    Session to manage
    :param session: session
    """
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
