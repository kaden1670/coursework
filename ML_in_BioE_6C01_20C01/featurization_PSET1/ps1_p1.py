###################
##Problem 1.1##
###################
import numpy as np
import random
from scipy import stats

def phi_1(age, feedback):
	#age should be a np array

	#age will be represented in a one-hot vector in 5 year intervals (0-19 indicies)
	#feedback will be represented as a real value (0-2)
	feature_vector = np.zeros((21,len(age)))

	#find indices corresponding to the age ranges
	g5 = np.where(np.logical_and(age>=0, age<=5))
	g10 = np.where(np.logical_and(age>5, age<=10))
	g15 = np.where(np.logical_and(age>10, age<=15))
	g20 = np.where(np.logical_and(age>15, age<=20))
	g25 = np.where(np.logical_and(age>20, age<=25))
	g30 = np.where(np.logical_and(age>25, age<=30))
	g35 = np.where(np.logical_and(age>30, age<=35))
	g40 = np.where(np.logical_and(age>35, age<=40))
	g45 = np.where(np.logical_and(age>40, age<=45))
	g50 = np.where(np.logical_and(age>45, age<=50))
	g55 = np.where(np.logical_and(age>50, age<=55))
	g60 = np.where(np.logical_and(age>55, age<=60))
	g65 = np.where(np.logical_and(age>60, age<=65))
	g70 = np.where(np.logical_and(age>65, age<=70))
	g75 = np.where(np.logical_and(age>70, age<=75))
	g80 = np.where(np.logical_and(age>75, age<=80))
	g85 = np.where(np.logical_and(age>80, age<=85))
	g90 = np.where(np.logical_and(age>85, age<=90))
	g95 = np.where(np.logical_and(age>90, age<=95))
	g100 = np.where(np.logical_and(age>95, age<=100))

	#make one-hot vector
	feature_vector[0,g5] = 1
	feature_vector[1,g10] = 1
	feature_vector[2,g15] = 1
	feature_vector[3,g20] = 1
	feature_vector[4,g25] = 1
	feature_vector[5,g30] = 1
	feature_vector[6,g35] = 1
	feature_vector[7,g40] = 1
	feature_vector[8,g45] = 1
	feature_vector[9,g50] = 1
	feature_vector[10,g55] = 1
	feature_vector[11,g60] = 1
	feature_vector[12,g65] = 1
	feature_vector[13,g70] = 1
	feature_vector[14,g75] = 1
	feature_vector[15,g80] = 1
	feature_vector[16,g85] = 1
	feature_vector[17,g90] = 1
	feature_vector[18,g95] = 1
	feature_vector[19,g100] = 1

	for i in list(range(0,len(feedback))):
		if feedback[i] == 'unhappy':
			feature_vector[20,i] = 0
		elif feedback[i] == 'satisfied':
			feature_vector[20,i] = 1
		else:
			feature_vector[20,i] = 2

	return feature_vector


# Test for 1.1 #

feedback_options = ["happy", "unhappy", 'satisfied']

#generate 10 random ages
age = np.random.randint(100, size = 10)

#generate 10 random feedbacks
feedback = random.choices(feedback_options, k=10)

#print(phi_1(age,feedback))


###################
##  Problem 1.2  ##
###################

# Features for driver safety: 
#Number of times the driver broke the speed limit by 5mph or less, 5-10mph, 10-15 mph, 15-20 mph, 
#20-25 mph, or 25+ mph
# length of time driving
# driving frequency
# most common location

# It is fair to assume that the magnitude of speeding scales with danger, so it would be a meaningful feature.
# Driving is inherantly dangerous, so the time driving should also scale with danger.
# Accidents often occur closest to home or work, so the frequency one drives also scales with danger.
# Lastly, location may affect safety due to weather, traffic, etc.


'''
The logs are formatted in the following way
						  time | recorded speed | location ID
						  
time            : An integer signifying a Unix timestamp.
												You have the option to sort timestamps to derive any meaningful information
recorded_speed  : A positive integer denoting speeds in MPH
location ID     : An integer denoting a location ID

You can choose to use this list to test your solution.
'''
logs = [
"1643733878 | 55 | 12344",
"1643743844 | 32 | 1264",
"1643754523 | 45 | 166",
"1643763976 | 89 | 128569",
]

'''
Returns a random speed limit for a given location ID
You can choose to use this implementation to test your solution.
'''
def get_speed_limit(loc_id):
	speed_limits = [15, 25, 35, 45, 50, 55, 65, 75]
	r_idx = random.randint(0,len(speed_limits)-1)
	return speed_limits[r_idx]

'''
Returns a random 8 letter location name for a given location ID
You can choose to use this implementation to test your solution.
'''
def get_location_name(loc_id, length=8):
	
	return ''.join(random.choice(string.ascii_uppercase) for _ in range(length))


def parse_logs(logs_string):
	'''Helper function for phi_2 to extract the details (integers) out of the string.
	Given a single log (string), return relevant details about a user.

	Hint: consider using the split function to split based on a delimiter '''
	
	log_sorted = logs_string.split(" | ")
	log_int = log_sorted
	log_int[0] = int(log_sorted[0])
	log_int[1] = int(log_sorted[1])
	log_int[2] = int(log_sorted[2])

	return log_int


def phi_2(user_log):

	'''
	Use the logs to return a list of features.
	  
	Args:
			user_log (list): a list of size <num_entries> containing log strings for a given driver

	Return:
			a list of size n (n>=4), where each item in the list is a feature for the given driver

	You can assume that get_speed_limit(loc_id) and get_location_name(loc_id) provide an integer and a string respectively corresponding 
	to a loc_id
	You can then call these functions in your code to retrieve information regarding speed limits and location names.
	'''

	# This log would contain information for one user

	feature_vector2 = np.zeros(9)

	#fill in time driving feature
	feature_vector2[6] = len(user_log)

	#log_ints is user_log but in integers since the function said only split by each log
	log_ints = np.zeros((len(user_log),3))

	for i in list(range(0,len(user_log))):

		logs_string = user_log[i]

		#time, recorded speed, location id
		log_int = parse_logs(logs_string)
		
		log_ints[i,:] = np.array([log_int])


		#fill in speeding features
		if 0 < log_int[1] - get_speed_limit(log_int[1]) <= 5:
			feature_vector2[0] = feature_vector2[0] + 1

		elif 5 < log_int[1] - get_speed_limit(log_int[1]) > 10:
			feature_vector2[1] = feature_vector2[1] + 1

		elif 10 < log_int[1] - get_speed_limit(log_int[1]) > 5:
			feature_vector2[2] = feature_vector2[2] + 1

		elif 15 < log_int[1] - get_speed_limit(log_int[1]) > 20:
			feature_vector2[3] = feature_vector2[3] + 1

		elif 20 < log_int[1] - get_speed_limit(log_int[1]) > 20:
			feature_vector2[4] = feature_vector2[4] + 1

		elif log_int[1] - get_speed_limit(log_int[1]) > 25:
			feature_vector2[5] = feature_vector2[5] + 1


		#fill in frequency
		# if not first index and the difference between timestamps is more than 5 minutes
		if i != 0 and abs(log_int[0]-log_ints[i-1, 0]) > 5 * 60:
			feature_vector2[7] = feature_vector2[7] + 1


	#fill in most frequent location

	feature_vector2[8] = stats.mode(log_ints[:,2],axis=None)[0]

	return feature_vector2

		# Hint: suggested code structure
		# x = np.zeros(n) # Create an x vector (list) containing n entries, where n is at least 4
		# TODO: populate the values of x e.g x[0] = some_features
		# return x
print(phi_2(logs))