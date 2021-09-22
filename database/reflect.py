import logging

from sqlalchemy import Table, inspect
from sqlalchemy import event
from sqlalchemy.orm import mapper, clear_mappers
from sqlalchemy.orm.base import _is_mapped_class

from methods.Concurrency import threading


@event.listens_for(Table, "column_reflect")
def column_reflect(inspector, table, column_info):
    """
    Database cells alias set 1st letter of the database name
    """
    # set column.key = "attr_<lower_case_name>"
    if column_info['name'].lower() != 'id':
        column_info['key'] = f"{str(table)}_{column_info['name'].lower()}"
    # print(column_info['key'])


class ReflectedTable(object):
    """Base class for database objects that are mapped to tables by reflection.
    """
    __tablename__ = None

    def __init__(self, **kwargs):
        vars(self).update(kwargs)

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
        id = None
        datas_ot = None
        datas_alias = None
        datas_setcode = None
        datas_type = None
        datas_atk = None
        datas_def = None
        datas_level = None
        datas_race = None
        datas_attribute = None
        datas_category = None


    class Texts(ReflectedTable):
        __tablename__ = "texts"
        id = None
        texts_name = None
        texts_desc = None
        texts_str1 = None
        texts_str2 = None
        texts_str3 = None
        texts_str4 = None
        texts_str5 = None
        texts_str6 = None
        texts_str7 = None
        texts_str8 = None
        texts_str9 = None
        texts_str10 = None
        texts_str11 = None
        texts_str12 = None
        texts_str13 = None
        texts_str14 = None
        texts_str15 = None
        texts_str16 = None
except:
    pass


@threading(workers=2)
def reflect(*args, **kwargs):
    if "database" not in kwargs:
        logging.exception(f'Database is missing')
    if _is_mapped_class(args[0]):
        clear_mappers()
    _class = args[0]
    logging.info(f'Reflecting {_class.__tablename__} from {kwargs["database"].engine}')
    table = Table(_class.__tablename__, kwargs["database"].MetaData, autoload=True)
    mapper(_class, table)
    # logging.info(_class.__tablename__)
