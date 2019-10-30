from datetime import datetime

from pony.orm.core import db_session, commit


def now():
    return int(datetime.timestamp(datetime.now()))


class DatabaseMethods:
    def __init__(self, cls):
        self.cls = cls

    @db_session
    def __add__(self, *args, **kwargs):
        if not kwargs or len(args) > 0:
            if self.cls.__name__ == 'Organisation':
                kwargs = {'Name': args[0],
                          'Description': args[1],
                          'Position': args[2]}
        just_now = now()
        kwargs.update({'created': just_now,
                       'modified': just_now,
                       'accessed': just_now})
        current = self.cls(**kwargs)
        commit()
        kwargs.update({'id': current.id})
        return kwargs

    @db_session
    def __update__(self, *args, **kwargs):
        if not kwargs or len(args) > 0:
            if self.cls.__name__ == 'Organisation':
                kwargs = {'id': args[0],
                          'Name': args[1],
                          'Description': args[2],
                          'Position': args[3]}
        kwargs.update({'modified': now()})
        self.cls.set(self.cls[kwargs['id']], **kwargs)
        return kwargs

    @db_session
    def __get__(self, id):
        try:
            item = self._get_dict(self.cls[id])
            item.update({'accessed': now()})
            self.cls.set(self.cls[id], **item)
            return item
        except Exception as e:
            return e

    @db_session
    def __delete__(self, id):
        try:
            elm = self.__get__(id)
            self.cls[id].delete()
            return elm
        except Exception as e:
            return e

    @db_session
    def __all__(self):
        return [self._get_dict(obj) for obj in self.cls.select()]

    def _get_dict(self, obj):
        return {attr.name: attr.__get__(obj) for attr in obj._attrs_}
