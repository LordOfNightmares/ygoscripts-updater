from datetime import datetime

from sqlalchemy.orm import create_session, mapper

from database.DatabaseTables import *


def now():
    return int(datetime.timestamp(datetime.now()))


class DatabaseMethods(Tables):
    def __init__(self,
                 *engines,
                 in_session=0,
                 out_session=0):
        self.engines = engines
        self.in_session = in_session
        self.out_session = out_session

        super().__init__(self.engines[self.in_session])
        self.sessions = [create_session(bind=engine) for engine in self.engines]
        self.session = self.sessions[self.out_session]

    def _commit_(self):
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
    def add_column(self, table_name, column, database=0):
        """
        not tested
        example:
            column = Column('new column', String(100), primary_key=True)
            add_column(engine, table_name, column)
        """

        column_name = column.compile(dialect=self.engines[database].dialect)
        column_type = column.type.compile(self.engines[database].dialect)
        self.engines[database].execute('ALTER TABLE %s ADD COLUMN %s %s' % (table_name, column_name, column_type))

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
