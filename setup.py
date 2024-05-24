"""
This is the setup module for the weewx docker project.

Based on:

- https://packaging.python.org/distributing/
- https://github.com/pypa/sampleproject/blob/master/setup.py
- https://blog.ionelmc.ro/2014/05/25/python-packaging/#the-structure
"""

# Standard Python Libraries
from glob import glob
from os.path import basename, splitext

# Third-Party Libraries
from setuptools import find_packages, setup


def readme():
    """Read in and return the contents of the project's README.md file."""
    with open("README.md", encoding="utf-8") as f:
        return f.read()


def package_vars(version_file):
    """Read in and return the variables defined by the version_file."""
    pkg_vars = {}
    with open(version_file) as f:
        exec(f.read(), pkg_vars)  # nosec
    return pkg_vars


setup(
    name="weewx_docker",
    # Versions should comply with PEP440
    version=package_vars("src/_version.py")["__version__"],
    description="weewx_docker python library",
    long_description=readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/felddy",
    # The project's main homepage
    download_url="https://github.com/felddy/weewx-docker",
    # Author details
    author="Mark Feldhousen",
    author_email="markf@geekpad.com",
    license="License :: OSI Approved :: MIT License",
    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Environment :: Web Environment",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.12",
        "Topic :: Scientific/Engineering :: Atmospheric Science",
    ],
    python_requires=">=3.6",
    # What does your project relate to?
    keywords="weewx",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    py_modules=[splitext(basename(path))[0] for path in glob("src/*.py")],
    install_requires=[
        "configobj == 5.0.9",
        "pyserial == 3.5",
        "pyusb == 1.2.1",
        "semver == 3.0.2",
        "setuptools == 75.6.0",
        "weewx == 5.1.0",
        "wheel == 0.45.1",
    ],
    extras_require={
        "test": [
            "coverage",
            "coveralls",
            "docker",
            "pre-commit",
            "pytest",
            "pytest-cov",
        ]
    },
)
