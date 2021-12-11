import concurrent.futures
from functools import wraps, partial


def threading(func=None, *, workers=4):
    if func is None:
        return partial(threading, workers=workers)

    @wraps(func)
    def wrapper(*args, **kwargs):
        # print(f"{args=}")
        # print(f"{kwargs=}")
        largs = len(args) > 0
        lkwargs = len(kwargs) > 0
        with concurrent.futures.ThreadPoolExecutor(max_workers=workers, thread_name_prefix='T') as executor:
            if largs and lkwargs:
                futures = [executor.submit(func, *arg, *args[1:], **kwargs) for arg in zip(args[0])]
            elif largs:
                futures = [executor.submit(func, *arg, *args[1:]) for arg in zip(args[0])]
            elif lkwargs:
                futures = [executor.submit(func, *kw, **kwargs) for kw in zip(kwargs)]
            return [future.result() for future in concurrent.futures.as_completed(futures) if future.done()]
    return wrapper

# with concurrent.futures.ThreadPoolExecutor(max_workers=10, thread_name_prefix='T') as executor:
#     futures = [executor.submit(func, *arg) for arg in zip(args[0])]

# # -----------------------------------TEST-----------------------------------
# import logging
#
# logging.basicConfig(format='%(asctime)s| %(threadName)s | %(levelname)-5s| %(message)s',
#                     level=logging.WARNING,
#                     datefmt="%H:%M:%S")
#
# import GeneralMethods


# # workers = 10
# # from memory_profiler import profile
# # @profile(precision=4)
# # def test():
# #     pass
#
# @GeneralMethods.time_it
# @threading(workers=2)
# def test(*args, **kwargs):
#     # print(kwargs)
#     response = args[0]
#     try:
#         logging.info(f'{args=}\t{kwargs=}\t{response=}')
#         # yield response, kwargs
#         return response
#     except Exception:
#         logging.exception(f'Exception:\n\nItem:{args}\n\n')

# if __name__ == '__main__':
#     vals = range(10)
#     kw = {'a': 1, "b": 2, "c": 3}
#     wk = {'a1': True, "b2": False, "c3": None}
#
#     print("ANS: ", test(vals), '\n')
#     print("ANS: ", test(*kw), '\n')
#     print("ANS: ", test(*wk), '\n')
#     print("ANS: ", test(**wk), '\n')
#     print("ANS: ", test(*kw, **wk), '\n')

# # print(f'{test(vals,ok=1,zok=2)=}')
