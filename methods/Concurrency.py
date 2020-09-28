import concurrent.futures
import logging
import traceback

from methods.GeneralMethods import time_it


class Concurrency:
    def __init__(self, args=None):
        my_form = '%(asctime)s:\t%(threadName)s:\t%(message)s'
        logging.basicConfig(format=my_form,
                            level=logging.DEBUG,
                            datefmt="%H:%M:%S")
        self.all_instances = []
        self.args = args

    @time_it
    def get(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=10, thread_name_prefix='T') as executor:
            for args, instance in zip(self.args, executor.map(self.send_instance, self.args)):
                try:
                    if instance:
                        self.all_instances.append(instance)
                except:
                    pass
        return self.all_instances

    def send_instance(self, *item):
        try:
            return self.process(item)
        except:
            logging.warning(f'\nException:\n'
                            f'Item:{item}\n'
                            f'\n{traceback.format_exc()}')
            # raise Exception

    def process(self, item):
        response = item
        logging.info(f'DOWN\t{item[0]=}\t{response=}')
        return response
