
# Setting Python Executable Version
import sys, os
os.environ['PYSPARK_PYTHON'] = sys.executable
os.environ['PYSPARK_DRIVER_PYTHON'] = sys.executable

# Making an empty output file
output_file = "Q2_output.txt"
with open(output_file, "w") as f:
    f.write("")

# Improting pyspark
from pyspark.sql import SparkSession

# Starting a SparkSession
spark = SparkSession \
    .builder \
    .appName("Big Data Assignment 1") \
    .getOrCreate()

sc1 = spark.sparkContext # Creating StreamingContext object


INPUT_FILE_LOCATION = "./spam.csv"  # Location of the dataset

# Making schema for reading the dataset 
# Two columns => v1 and v2
# v1 => Spam / Ham
# v2 => SMS
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
    words_with_non_stop_words = [word for word in words_without_punctuations if word.lower() not in stopwords_set]
    filtered_words = [word for word in words_with_non_stop_words if len(word)!=0]
    return filtered_words


# Filtering the stopwords and punctutations from SMSs
dataframe = dataframe.mapValues(lambda x: remove_stop_words(x))


# Mapping flat every word with ham/spam key
non_stop_word_rows = dataframe.flatMapValues(lambda x: x)


# Filtering on the basis of spam and non-spam rows
non_spam_rows = non_stop_word_rows.filter(lambda x: x[0]=="ham")
spam_rows = non_stop_word_rows.filter(lambda x: x[0]!="ham") # or =="spam"

# Generating the pairs count frequency for both spam and non-spam RDDs
non_spam_words_freq = non_spam_rows.map(lambda x: (x[1], 1))
spam_words_freq = spam_rows.map(lambda x: (x[1], 1))

non_spam_words_count = non_spam_words_freq.reduceByKey(lambda x, y: x+y)
spam_words_count = spam_words_freq.reduceByKey(lambda x, y: x+y)


# Getting the topmost 5 words matching with the list of words given
list_of_words_to_be_checked = ["home", "super", "call"]
output = "" # Variable for storing the output
for word in list_of_words_to_be_checked:
    # Filtering the words containing the current word
    non_spam_occurence_frequent_words = non_spam_words_count.filter(lambda x: word in x[0].lower())
    spam_occurence_frequent_words = spam_words_count.filter(lambda x: word in x[0].lower())

    # Sorting by occurences and taking 5-topmost
    topmost_5_non_spam_words = non_spam_occurence_frequent_words.sortBy(lambda x: -x[1]).take(5)
    topmost_5_spam_words = spam_occurence_frequent_words.sortBy(lambda x: -x[1]).take(5)

    # Getting list of words
    non_spam_words_occurences = [x[0] for x in topmost_5_non_spam_words]
    spam_words_occurences = [x[0] for x in topmost_5_spam_words]

    # Printing the words and saving the output
    if(len(non_spam_words_occurences)!=0):
        output += f"In NON-SPAM messages, word {word} occur in the following most occurring words:\n"
        output += " ".join(map(str, non_spam_words_occurences)) + "\n"
    else:
        output += f"In NON-SPAM messages, word {word} doesn't occur in any words\n"
    
    if(len(spam_words_occurences)!=0):
        output += f"In SPAM messages, word {word} occur in the following most occurring words:\n"
        output += " ".join(map(str, spam_words_occurences)) + "\n"
    else:
        output += f"In SPAM messages, word {word} doesn't occur in any words\n"
    output += "\n"

with open(output_file, "w") as f:
    f.write(output)

print(output)

# Stopping the Spark Session
spark.stop()


