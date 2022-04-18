# Setting Python Executable Version
import sys, os
os.environ['PYSPARK_PYTHON'] = sys.executable
os.environ['PYSPARK_DRIVER_PYTHON'] = sys.executable

# Importing pyspark
from pyspark.sql import SparkSession

# Starting a SparkSession
spark = SparkSession \
    .builder \
    .appName("Big Data Assignment 2") \
    .getOrCreate()

sc = spark.sparkContext # Creating StreamingContext object

INPUT_FILE_LOCATION = "Wiki-Vote.txt"  # Location of the dataset
# Reading data from the file
row_entries = []
with open(INPUT_FILE_LOCATION) as file:
    lines = file.readlines()

# Ignoring the first 4 commented lines
lines = lines[4:]

# Parallizing the input data dataframe
row_entries = sc.parallelize(lines)

# Getting edges
edges = row_entries.map(lambda x: tuple(x.split()))
# Getting vertices
flat_edges = edges.flatMap(lambda x: x)
vertices = flat_edges.distinct()

# Number of vertices
num_vertices = vertices.count()

# List of vertices
vertices_list = vertices.collect()

# Creating in-adjacency list
out_adjacency_list = edges.groupByKey().mapValues(list).collectAsMap()
# Creating out-adjacency list
reversed_edges = edges.map(lambda x: (x[1], x[0]))
in_adjacency_list = reversed_edges.groupByKey().mapValues(list).collectAsMap()

# Initialising the authority and hub scores
curr_authority_scores = dict()
curr_hub_scores = dict()
for vertex_id in vertices_list:
    curr_authority_scores[vertex_id] = 1/num_vertices
    curr_hub_scores[vertex_id] = 1/num_vertices

def get_next_iter_auth_score(vertex_id):
    '''
    Function to compute the next iteration authority score of a vertex
    '''
    vertex_in_adjacency_list = in_adjacency_list.get(vertex_id, [])
    vertex_curr_auth_score = 0
    for in_node in vertex_in_adjacency_list:
        vertex_curr_auth_score += last_hub_scores[in_node]
    return vertex_curr_auth_score

def get_next_iter_hub_score(vertex_id):
    '''
    Function to compute the next iteration hub score of a vertex
    '''
    vertex_out_adjacency_list = out_adjacency_list.get(vertex_id, [])
    vertex_curr_hub_score = 0
    for out_node in vertex_out_adjacency_list:
        vertex_curr_hub_score += last_authority_scores[out_node]
    return vertex_curr_hub_score

num_iterations = 100
for _ in range(num_iterations):
    # Copying the hub and authority scores to compute the next iteration scores
    last_authority_scores = curr_authority_scores.copy()
    last_hub_scores = curr_hub_scores.copy()
    # Initializing sa and sh for normalizing scores at the end of iteration
    sa = 0
    sh = 0
    # Calculating the new hub and authority scores of each nodes
    for vertex in vertices_list:
        # Updating the Authority Scores
        curr_authority_scores[vertex] = get_next_iter_auth_score(vertex)
        # Updating the Hub Scores
        curr_hub_scores[vertex] = get_next_iter_hub_score(vertex)
        # Adding Sa and Sh for normalization
        sa += curr_authority_scores[vertex]
        sh += curr_hub_scores[vertex]
    
    # Normalizing the scores at the end of the iteration
    for vertex in vertices_list:
        curr_authority_scores[vertex] /= sa
        curr_hub_scores[vertex] /= sh
    
    # Clearing the copied last scores to avoid the memory leak 
    last_authority_scores.clear()
    last_hub_scores.clear()

# Storing scores with vertex id to output
output_data = []

try:
    # Sorting by converting Node ID to int
    vertices_list.sort(key=lambda x: int(x))    
except Exception as e:
    pass

for vertex in vertices_list:
    vertex_auth_score = curr_authority_scores.get(vertex, 0)
    vertex_hub_score = curr_hub_scores.get(vertex, 0)
    output_data.append((vertex, vertex_hub_score, vertex_auth_score))

# Creating the dataframe
rdd = sc.parallelize(output_data)
dfFromRDD = rdd.toDF()

# Setting the headers for printing to the csv file
rdd_with_headers = dfFromRDD.withColumnRenamed("_1", "Node ID") \
    .withColumnRenamed("_2", "Hub Score") \
    .withColumnRenamed("_3", "Authority Score")

# Printing the dataframe to a csv file
OUTPUT_FILE_LOCATION = "output.csv"
columns = ["Node ID", "Hub Score", "Authority Score"]
rdd_with_headers.toPandas().to_csv(OUTPUT_FILE_LOCATION, index=False, header=columns)