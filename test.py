import os
from pprint import pprint

from methods.GeneralMethods import md5
from methods.configuration import Config

config = Config('checksum.yaml').load()
print()
path = 'script'
cur = {}
pprint(config['Aerrata']['c10000010.lua'])
for file in os.listdir(path):
    current_file_checksum = md5(os.path.join(path, file))
    # print(map(file, current_file_checksum))
    if file =='c10000010.lua':
        cur.update({file: current_file_checksum})
pprint(cur['c10000010.lua'])
