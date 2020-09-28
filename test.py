# import os
# from pprint import pprint
#
# from methods.GeneralStructs import md5
# from methods.configuration import YamlManager
#
# config = YamlManager('checksum.yaml').load()
# print()
# path = 'script'
# cur = {}
# pprint(config['Aerrata']['c10000010.lua'])
# for file in os.listdir(path):
#     current_file_checksum = md5(os.path.join(path, file))
#     # print(map(file, current_file_checksum))
#     if file =='c10000010.lua':
#         cur.update({file: current_file_checksum})
# pprint(cur['c10000010.lua'])
# test = {
#     "one": 1,
#     "two": 2,
#     "three": 3
# }
# print({"one": 1}.items() <= test.items())
# a=['ygorepos\\mycard-ygopro-database']
# b= ['ygorepos\\ProjectIgnis-DeltaHopeHarbinger',
#     'ygorepos\\mycard-ygopro-database',
#     'ygorepos\\Fluorohydride-ygopro-pre-script',
#     'ygorepos\\Fluorohydride-ygopro-scripts']
# print(set(a)<=(set(b)))
#
# """
# 1: 'mycard-ygopro-database': None is surplus
# """
# from pprint import pprint
#
# a = {'Aerrata': {},
#      'Fluorohydride-ygopro-pre-script': {},
#      'Fluorohydride-ygopro-scripts': {},
#      'ProjectIgnis-DeltaHopeHarbinger': {},
#      'mycard-ygopro-database': {}}
# """
# 2: 'Fluorohydride-ygopro-pre-script': None is missing
# """
# b = {'Aerrata': {},
#      'Fluorohydride-ygopro-scripts': {},
#      'ProjectIgnis-DeltaHopeHarbinger': {}}
# """
# 3: both cases
# """
# d = {}
# """
# What exists
# """
# c = {'Aerrata': {},
#      'Fluorohydride-ygopro-pre-script': {},
#      'Fluorohydride-ygopro-scripts': {},
#      'ProjectIgnis-DeltaHopeHarbinger': {}}
#
# for i in c:
#     if i not in d:
#         d[i] = {}
# for i in d.copy():
#     if i not in c:
#         d.pop(i)
# d['Aerrata'].update({1:2})
# pprint(d)

lst = ['a.txt',
       'a-b.txt']
lst.sort()
print(lst)
