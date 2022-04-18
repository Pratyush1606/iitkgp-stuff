import os
from pathlib import Path

q1 = Path("Assignment1_Q1.py")
q2 = Path("Assignment1_Q2.py")

os.system("python {}".format(q1))
os.system("python {}".format(q2))