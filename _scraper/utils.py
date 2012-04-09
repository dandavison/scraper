import os
import pickle
from functools import wraps


class cache_to_pickle(object):
    """
    Function decorator to cache output of function to a file.

    file - the pickle file path to cache output to.
    file_function - a function to dynamically generate the cache file path.

    One and only one of file parameters *must* be specified.
    """
    def __init__(self, file=None, file_function=None):
        assert bool(file) ^ bool(file_function)

        self.file_function = file_function

        # Default file function - just return file argument.
        if not self.file_function:
            self.file_function = lambda *args, **kwargs: file

    def __call__(self, function):
        @wraps(function)
        def function_pickle(*args, **kwargs):
            pickle_file = self.file_function(*args, **kwargs)

            # Run the function if the pickle file is not there or empty.
            if not os.path.exists(pickle_file):
                data = function(*args, **kwargs)
                with open(pickle_file, "wb") as fp:
                    pickle.dump(data, fp)
            else:
                with open(pickle_file) as fp:
                    data = pickle.load(fp)

            return data

        return function_pickle
