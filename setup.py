# setup.py

from setuptools import setup, Extension
from Cython.Build import cythonize
import sys

# --- Get the long description from the README file ---
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# --- Platform-specific compiler arguments ---
if sys.platform == "win32":
    # Windows (MSVC)
    extra_compile_args = ['/Ox', '/fp:fast', '/openmp']
    extra_link_args = ['/openmp']
else:
    # Linux/macOS (GCC/Clang)
    extra_compile_args = ['-O3', '-ffast-math', '-fopenmp']
    extra_link_args = ['-fopenmp']

# --- Define the Cython extension ---
# The name "matthewsort.MatthewSort" matches the folder/file structure.
extensions = [
    Extension(
        name="matthewsort.MatthewSort",
        sources=["matthewsort/MatthewSort.pyx"],
        language="c++",
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_link_args,
    )
]

# --- Setup configuration ---
setup(
    name="matthewsort",
    version="0.1.6", # Match the version in __init__.py
    author="Matthew",
    author_email="matthew.hill@mail.utoronto.ca",
    description="An incredibly fast, multithreaded sorting algorithm implemented in Cython.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Hylium/matthewsort-project", # Link to your GitHub repo
    packages=['matthewsort'], # Tell setuptools to include the 'matthewsort' package
    ext_modules=cythonize(extensions),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering",
        "Intended Audience :: Developers",
    ],
    python_requires='>=3.7',
)