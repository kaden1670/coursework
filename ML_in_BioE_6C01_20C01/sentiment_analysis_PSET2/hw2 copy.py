from collections import Counter
import numpy as np
import matplotlib.pyplot as plt

def load_sent(path):
    """
    load sentences from the file <path>.
    
    Return:
      a list of setences, where each setence is a list of strings.
      the first sentence in <positive.txt> should be of the form: ['excellent', 'food', '.']
    """
    sents = []
    with open(path) as f:
        for line in f:
            sents.append(line.split())
    return sents

def build(sents, min_freq=10):
    """
    build the vocabulary from the sentences <sents>, include all words that appear more than <min_freq> times.
    
    Return:
      a list of strings (words), where each string is a token appeared in <sents>.
    
    Example: 
      sents = [['I', 'like', 'banana'], ['I', 'like', 'apple']]
      min_freq = 1
      Output: ['I', 'like', 'banana', 'apple', '<oov>'] (order doesn't matter)
    """
    v = ['<oov>']

    # code to build your vocabulary goes here
    flat_sents = [item for sublist in sents for item in sublist]
    unique_elem = list(set(flat_sents))

    for i in unique_elem:
      if flat_sents.count(i) >= min_freq:
        v.append(i)
    
    return v

# Question 1.1
# #############################
# include updated copy of build funtion in your submission
#####################################
sents = load_sent('./positive.txt') + load_sent('./negative.txt')
#words are counted multiple times in each sentement

# vocab = build(sents, 10)
# sents_with_oov = np.zeros(0,15)
# for sent in sents:
#   for word in sent:
#     if word in vocab:




# Question 1.3
oov = [] # list to store number of sentences with atleast 1 oov for each t.
t = list(range(1,16))

# #############################
# Your code goes here
sents_with_oov = np.zeros((1,15))[0]
for j in t:
  print('progress')
  print(j)
  vocab = build(sents, j)
  for sent in sents:
    for word in sent:
      if word not in vocab:
        sents_with_oov[j] = sents_with_oov[j] +1
        break

oov = np.ndarray.tolist(sents_with_oov)

  
#####################################


"""
Plotting code: You can use this to plot if you want or write your own.
"""
fig = plt.figure(figsize=(5, 3))
plt.plot(t, oov, '--ro')
plt.ylabel('# sentences w/oov')
plt.xlabel('t')
plt.title('# of sentences w/oov vs. t')
plt.tight_layout()
fig.savefig('./oov_size_vs_t.png') # Include this figure in your submission.

# Question 1.6a
# update the build function to include bigrams
# #############################
# include updated copy of build funtion in your submission
#####################################

sents = load_sent('./positive.txt') + load_sent('./negative.txt')
vocab = build(sents, 10)
print(len(vocab))


# Question 1.6b
pos_sents = load_sent('./positive.txt') 
neg_sents = load_sent('./negative.txt')

# #############################

#####################################