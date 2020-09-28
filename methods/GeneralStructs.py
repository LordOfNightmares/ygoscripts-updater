import json
from decimal import Decimal

import yaml


class Mapping(dict):
    def __setitem__(self, key, item):
        self.__dict__[key] = item

    def __getitem__(self, key):
        return self.__dict__[key]

    def __repr__(self):
        return repr(self.__dict__)

    def __len__(self):
        return len(self.__dict__)

    def __delitem__(self, key):
        del self.__dict__[key]

    def clear(self):
        return self.__dict__.clear()

    def copy(self):
        return self.__dict__.copy()

    def has_key(self, k):
        return k in self.__dict__

    def update(self, *args, **kwargs):
        return self.__dict__.update(*args, **kwargs)

    def keys(self):
        return self.__dict__.keys()

    def values(self):
        return self.__dict__.values()

    def items(self):
        return self.__dict__.items()

    def pop(self, *args):
        return self.__dict__.pop(*args)

    def __cmp__(self, dict_):
        return self.__cmp__(self.__dict__, dict_)

    def __contains__(self, item):
        return item in self.__dict__

    def __iter__(self):
        return iter(self.__dict__)

    # def __unicode__(self):
    #     return unicode(repr(self.__dict__))


class fakefloat(float):
    def __init__(self, value):
        super().__init__()
        self._value = value

    def __repr__(self):
        return str(self._value)


class ComplexEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            # Subclass float with custom repr?
            try:
                return fakefloat(obj)
            except:
                raise TypeError(repr(obj) + " is not JSON serializable")
        # Let the base class default method raise the TypeError
        return json.JSONEncoder.default(self, obj)


