from pony.orm.core import PrimaryKey, Required
from pony.orm.core import *
from app import db


class Organisation(db.Entity):
    id = PrimaryKey(int, auto=True)
    Name = Optional(str)
    Description = Optional(str)
    Position = Optional(str)
    created = Optional(int)
    modified = Optional(int)
    accessed = Optional(int)


db.generate_mapping(create_tables=True)
