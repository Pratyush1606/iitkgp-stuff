# Big Data Processing (Spring 2022) Assignment 2

Submitted By:
> Abhishek Suresh Pachorkar, 18MA20001  
> Mukul Mehta, 18CS10033  
> Nuruddin Jiruwala, 18EE35022  
> Pratyush Jaiswal, 18EE35014  
> Ram Niwas Sharma, 18CS10044  
> Soumick Pyne, 18AE3AI04  
------------

## System Requirements

- Java
- Python Interpreter used: Python 3.10.4
  The code should run in any version of Python >= 3.7
- PySpark 3.2.1

> The dependencies have been frozen inside the requirements.txt file, and if you're working in a python virtual environment, the dependencies can be installed using the command  
"pip install -r requirements.txt".

------------

## Folder structure

```
Assignment2
├── output.csv
├── README.md
├── requirements.txt
├── solution.py
└── Wiki-Vote.txt
```

- `output.csv` contains the output with three columns mentioned in the assignment.
- `README.md` is a readme file containing all the instructions for running the assignment.
- `requirements.txt` contains all the dependencies with correct versions.
- `solution.py` is a python script which will run the code and generate the output file.
- `Wiki-Vote.txt` contains the data from the link mentioned in the Assignment.

------------

## Running Instructions

> Use `pip` or `pip3` and `python` or `python3` as per your system configuration for executing the below commands

1. First, change the working directory to this folder

2. It is advised to work inside a virtual environment. Make a virtual environment and activate that.

3. Install all the dependencies
    ```
    pip install -r requirements.txt
    ```

4. Make sure `Java` is installed on the system and is added to the PATH.

5. Run python code, `solution.py`
    ```
    python solution.py
    ```
    It will generate the output file, `output.csv`.

> Sometimes, warnings can be seen in stdout.
