
# Setting Python Executable Version
import sys, os
os.environ['PYSPARK_PYTHON'] = sys.executable
os.environ['PYSPARK_DRIVER_PYTHON'] = sys.executable


# Improting pyspark
from pyspark.sql import SparkSession

# Starting a SparkSession
spark = SparkSession \
    .builder \
    .appName("Big Data Assignment 1") \
    .getOrCreate()

sc1 = spark.sparkContext # Creating StreamingContext object


INPUT_FILE_LOCATION = "spam.csv"  # Location of the dataset

'''
Making schema for reading the dataset 
Two columns => v1 and v2
v1 => Spam / Ham
v2 => SMS
'''
from pyspark.sql.types import StructType, StringType
schema = StructType() \
    .add("v1", StringType(), True)\
    .add("v2", StringType(), True)

# Creating a RDD from the input file
dataframe = spark.read \
    .options(header='True') \
    .schema(schema) \
    .csv(INPUT_FILE_LOCATION).rdd

# Changing the Row format to a pair format in dataframe
dataframe = dataframe.map(lambda x: (x.asDict()["v1"], x.asDict()["v2"]))
# Removing the rows with blank SMS
dataframe = dataframe.filter(lambda x: x[1]!=None)


# Reading data from stopwords.txt file
stopwords = spark.read \
    .options(delimiter="\n") \
    .text("stopwords.txt").rdd

# Changing the Row format to a single stopword per row
stopwords = stopwords.map(lambda x: x.asDict().get("value"))
stopwords_list = stopwords.collect()
# Storing all the stopwords in a set to make the time complexity of querying/finding O(1)
stopwords_set = set([x.lower() for x in stopwords_list])


'''
Function for filtering punctuations and stopwords
Input => A String
Output => A list of filtered words
'''
import re
def remove_stop_words(words):
    words = words.split()
    words_without_punctuations = list(map(lambda x: re.sub('[^0-9a-zA-Z]','', x), words))
    words_with_non_stop_words = [word.lower() for word in words_without_punctuations if word.lower() not in stopwords_set]
    filtered_words = [word for word in words_with_non_stop_words if len(word)!=0]
    return filtered_words


# Filtering the stopwords and punctutations from SMSs
dataframe = dataframe.mapValues(lambda x: remove_stop_words(x))


# Function for removing the duplicate words from a row
def remove_duplicates(words):
    words = list(set(words))
    return words


# Removing the duplicates in each rows
dataframe = dataframe.mapValues(lambda x: remove_duplicates(x))
# Removing the rows where no pairs are generated
filtered_dataframe_to_generate_pairs = dataframe.filter(lambda x: len(x[1])>1)


'''
Function for generating pairs
Input => A list of words
Output => A list of strings where every string element will be combination of 
two lexiographically sorted words separated with , in between
'''
def get_pairs(words):
    pairs = []
    for x in range(len(words)):
        for y in range(x+1, len(words)):
            pairs.append(",".join(sorted([words[x], words[y]])))
    return pairs


# Generating the pairs and mapping them to the key
pairs_dataframes = filtered_dataframe_to_generate_pairs.flatMapValues(lambda x: get_pairs(x))

# Removing the rows in which pair generated is having duplicate words
pairs_dataframes = pairs_dataframes.filter(lambda x: len(set(x[1].split(",")))==2)

# Filtering on the basis of spam and non-spam rows
non_spam_rows = pairs_dataframes.filter(lambda x: x[0]=="ham")
spam_rows = pairs_dataframes.filter(lambda x: x[0]!="ham")


# Generating the pairs count frequency for both spam and non-spam RDDs
non_spam_pairs_freq = non_spam_rows.map(lambda x: (x[1], 1))
spam_pairs_freq = spam_rows.map(lambda x: (x[1], 1))

non_spam_pairs_count = non_spam_pairs_freq.reduceByKey(lambda x, y: x+y)
spam_pairs_count = spam_pairs_freq.reduceByKey(lambda x, y: x+y)


# Splitting the key strings having word pairs with , as delimeter
non_spam_pairs_separated = non_spam_pairs_count.map(lambda x: (x[0].split(","), x[1]))
spam_pairs_separated = spam_pairs_count.map(lambda x: (x[0].split(","), x[1]))

# Mkaing the row a tuple of three elements with two words and their co-occurence count
non_spam_pairs_with_count_tuples = non_spam_pairs_separated.map(lambda x: (x[0][0], x[0][1], x[1]))
spam_pairs_with_count_tuples = spam_pairs_separated.map(lambda x: (x[0][0], x[0][1], x[1]))


# Sorting the rdd
non_spam_sorted = non_spam_pairs_with_count_tuples.sortBy(lambda x:(x[0], x[1], x[2]), True)
spam_sorted = spam_pairs_with_count_tuples.sortBy(lambda x:(x[0], x[1], x[2]), True)


# Converting the RDDs to dataframes to be saved
non_spam_df = non_spam_sorted.toDF()
spam_df = spam_sorted.toDF()


# Setting the headers for printing to the csv file
non_spam_df_with_colum_names = non_spam_df.withColumnRenamed("_1","Word1") \
    .withColumnRenamed("_2","Word2") \
    .withColumnRenamed("_3","Number of SMSs with co-occurences")
spam_df_with_colum_names = spam_df.withColumnRenamed("_1","Word1") \
    .withColumnRenamed("_2","Word2") \
    .withColumnRenamed("_3","Number of SMSs with co-occurences")


# Printing the dataframe to a csv file
non_spam_df_with_colum_names.toPandas().to_csv('Q1_non_spam_output.csv', index=False, header=["Word1", "Word2", "Number of SMSs with co-occurences"])
spam_df_with_colum_names.toPandas().to_csv('Q1_spam_output.csv', index=False, header=["Word1", "Word2", "Number of SMSs with co-occurences"])


# Stopping the Spark Session
spark.stop()


