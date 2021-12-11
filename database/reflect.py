import logging

from sqlalchemy import Table, inspect
from sqlalchemy import event
from sqlalchemy import exc
from sqlalchemy.orm import mapper, clear_mappers
from sqlalchemy.orm.base import _is_mapped_class

from methods.Concurrency import threading


@event.listens_for(Table, "column_reflect")
def column_reflect(inspector, table, column_info):
    """
    Database cells alias set 1st letter of the database name
    """
    # set column.key = "attr_<lower_case_name>"
    # if column_info['name'].lower() != 'id':
    #     column_info['key'] = f"{str(table)}_{column_info['name'].lower()}"
    # print(column_info['key'])


class NewTable(Table):
    def __iter__(self):
        for k, v in self.__dict__.items():
            yield k, v


class ReflectedTable(object):
    """Base class for database objects that are mapped to tables by reflection.
    """
    __tablename__ = None

    # __abstract__ = True

    def __init__(self, **kwargs):
        vars(self).update(kwargs)

    def __iter__(self):
        for k, v in self.__dict__.items():
            yield k, v

    def __repr__(self):
        return str(self._asdict())

    def _asdict(self):
        """
        Return dict of a query selection.
        """
        return {c.key: getattr(self, c.key) for c in inspect(self).mapper.column_attrs}


try:
    """class tables reflected 
    class Table(ReflectedTable):
        __tablename__ = 'actual table name'    
    """


    class Datas(ReflectedTable):
        __tablename__ = "datas"


    class Texts(ReflectedTable):
        __tablename__ = "texts"
except:
    pass


@threading(workers=2)
def reflect(*args, **kwargs):
    table = args[0]
    if "database" not in kwargs:
        logging.exception(f'Database is missing')
    db = kwargs["database"]
    if table is None:
        logging.exception(f'Table is missing')
    if _is_mapped_class(table):
        clear_mappers()
    logging.info(f'Reflecting {table.__tablename__} from {db.engine}')
    table_class = NewTable(table.__tablename__, db.MetaData, autoload=True)
    try:
        mapper(table, table_class)
    except exc.ArgumentError as a:
        if "could not assemble any primary key columns for mapped table" in str(a):
            # table_class.columns[0].primary_key = True
            for i, k in enumerate(table_class.columns.keys()):
                if k.endswith('name'):
                    table_class.columns[i].primary_key = True
                logging.warning(f'{k} PRIMARY-KEY: {table_class.columns[i].primary_key}')
    except Exception:
        raise
    # logging.info(_class.__tablename__)
