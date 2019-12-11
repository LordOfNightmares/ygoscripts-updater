from datetime import datetime

from sqlalchemy import create_engine
from sqlalchemy.orm import mapper, sessionmaker
from tqdm import tqdm

from database.DatabaseTables import *


def now():
    return int(datetime.timestamp(datetime.now()))


class DatabaseMethods(Tables):
    def __init__(self, engine):
        self.engine = engine
        super().__init__(self.engine)
        Session = sessionmaker(bind=engine)
        # self.session = create_session(bind=engine)
        self.session = Session()

    def commit(self):
        self.session.commit()

    def _close_(self):
        self.session.close()

    def __assign_table(self, table_name):
        return self.meta.tables[table_name]

    def __assign_mapped_table(self, table_name):
        return mapper(TempTable, self.meta.tables[table_name])

    def add(self, insert_dict: dict, table_name: str) -> None:
        """
        :param table_name: table name where the id is searched in
        :param insert_dict: dictionary to be inserted in database
        """
        table = self.__assign_table(table_name)
        # print(table)
        self.session.execute(table.insert(), insert_dict)

    def edit(self, update_dict: dict, table_name: str) -> None:
        """
        :param table_name: table name where the id is searched in
        :param update_dict: dictionary to be inserted in database
        """
        table = self.__assign_table(table_name)
        # print(table)
        self.session.execute(table.update().
                             where(table.columns.id == update_dict['id']),
                             update_dict)

    def delete(self, val, table_name: str):
        """
        :param val: row with val to be deleted
        :param table_name: table name where the id is searched in
        """
        table = self.__assign_table(table_name)
        # print(table)
        self.session.execute(table.delete().
                             where(table.columns.id == val))

    def get_id(self, id, table_name: str, __object=False) -> object or dict:
        """
        :param __object: True returns object False returns dict
        :param id: id existing in database
        :param table_name: table name where the id is searched in
        :return: object with tuples or dict
        """
        table = self.__assign_table(table_name)
        get_id_select = self.session.execute(table.select().
                                             where(table.columns.id == id))
        if __object:
            return get_id_select
        else:
            return [dict(i) for i in get_id_select][0]

    def get_tables(self):
        return list(self.meta.tables.keys())

    def get_select_all(self, table_name: str, __object=False) -> object or dict:
        """
        :param table_name: table name where we need all data
        :param __object: True returns object False returns dict
        :return: object with tuples or dict
        """
        table = self.__assign_table(table_name)
        get_select = self.session.execute(table.select())
        if __object:
            return get_select
        else:
            return [dict(i) for i in get_select]

    # temporarily unused
    '''
    def add_column(self, table_name, column):
        """
        not tested
        example:
            column = Column('new column', String(100), primary_key=True)
            add_column(engine, table_name, column)
        """

        column_name = column.compile(dialect=self.engine.dialect)
        column_type = column.type.compile(self.engine.dialect)
        self.engine.execute('ALTER TABLE %s ADD COLUMN %s %s' % (table_name, column_name, column_type))

    def get(self, value, table_name: str):
        """
        :param value: value existing in database
        :param table_name: table name where the value is searched in
        :return: object with the value from database
        """
        self.__assign_mapped_table(table_name)
        return self.session.query(TempTable).get(value)

    def get_all_query(self, table_name):
        """
        # not tested entirely for use
        :param table_name: table name where we need all data
        :return: query objects?
        """
        return self.session.query(self.__assign_table(table_name))
    '''


def merge_db(db1, db2, merge_form=True):
    print("--- {} --- {}".format(str(db1.engine)[17:-1], str(db2.engine)[17:-1]))
    for table_name in db1.get_tables():
        db1_select = db1.get_select_all(table_name)
        db2_select = db2.get_select_all(table_name)
        duplicates = [item1['id'] for item1 in db1_select for item2 in db2_select if item1['id'] == item2['id']]
        try:
            for item in tqdm(db2_select):
                if item['id'] in duplicates:
                    if not merge_form:
                        # print(item['name'])
                        db1.edit(item, table_name)
                else:
                    db1.add(item, table_name)
            print("{}:  {}-cards".format(table_name, len(db1.get_select_all(table_name))))
            db1.commit()
        except Exception as e:
            print("ERROR!: Merge Failed! on table:", table_name)
            print(e.__traceback__.tb_lineno, e)


def merge(output, dbs=None, merge_form=True):
    if dbs is None:
        raise Exception('No Databases found')
    engine_names = ['sqlite:///{}'.format(db) for db in dbs]
    engines = [create_engine(engine_name) for engine_name in engine_names]

    out_engine = create_engine('sqlite:///{}'.format(output))
    Tables(engines[0]).meta.create_all(out_engine)

    db1 = DatabaseMethods(out_engine)
    print("Databases merge in alphabet order")
    print("Merge by adding only:", merge_form)
    for engine in engines:
        db2 = DatabaseMethods(engine)
        merge_db(db1, db2, merge_form)
    # print(len(db1.get_select_all('texts')))
