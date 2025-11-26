# matthewsort/__init__.py

# This imports the functions from your compiled .pyd/.so file
# so users can do `from matthewsort import sort` instead of
# `from matthewsort.MatthewSort import sort`.
from .MatthewSort import sort, supersort

__version__ = "0.1.7" # Start with a version number