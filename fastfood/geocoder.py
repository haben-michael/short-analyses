import requests
import csv
import time
import random
import json

# ## 1. get geocoded addresses for bk, kfc

# # post_addr = 'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=%s&benchmark=4&format=json'

# # with open('geocoded_addresses.csv', 'r') as f:
# #     finished = list(csv.reader(f))
# # with open('fastfood_addresses.csv', 'r') as f:
# #     unfinished = list(csv.reader(f))
# # unfinished = unfinished[len(finished):]

# # # restaurant = unfinished[0]
# # for restaurant in unfinished:
# #     address = restaurant[1]
# #     matches = json.loads(requests.get(post_addr % address).text)['result']['addressMatches']
# #     row = {'restaurant' : restaurant[0], 'search_str' : restaurant[1]}
# #     row['parsed_address'],row['lat'],row['lon'] = [matches[0]['matchedAddress']]+matches[0]['coordinates'].values() if len(matches)>0 else ('NA','NA','NA')
        
# #     # try:
# #     #     geocoded = json.loads(response.text)['result']['addressMatches'][0]
# #     #     row = {'restaurant' : restaurant[0], 'search_string' : address, 'parsed_address' : geocoded['matchedAddress'], 'lat' : geocoded['coordinates']['y'], 'lon' : geocoded['coordinates']['x']}
# #     # except:
# #     #     row = {'restuarant' : restaurant[0], 'search_string' : address, 'prased_address' : response.text, 'lat' : 'NA', 'lon': 'NA'}
# #     with open('geocoded_addresses.csv', 'a') as f:
# #         csv.DictWriter(f,fieldnames=row.keys()).writerow(row)


# with open('scrapes/addresses.csv', 'r') as f:
#     unfinished = list(csv.reader(f))
    
# formatted = []
# for j in range(len(unfinished)):
#     unformatted = unfinished[j][1].split(', ')
#     if unformatted[-1] != 'US':
#         print 'skipping: ' + str(unformatted)
#         continue
#     # [str(j)] + unformatted[:2] + unformatted[2].split(' ')
#     formatted.append([str(j)] + [' '.join(unformatted[:-3])] + [unformatted[-3]] + unformatted[-2].split(' '))
#     # print(formatted)

# # ## fix manually added DC burger king
# # addresses = zip(*unfinished)[1]
# # r = re.compile('191 Chappie James')
# # filter(r.match,addresses)[0]

# with open('census_batch.csv', 'w') as f:
#     csv.writer(f).writerows(formatted)


# # 2. read in geocoded addresses from census

# with open('census_batch.csv', 'r') as f:
#     addresses = list(csv.reader(f))

# with open('GeocodeResults_1.csv', 'r') as f:
#     geocoded = list(csv.reader(f))

# with open('GeocodeResults_2.csv', 'r') as f:
#     geocoded += list(csv.reader(f))
    
# matched = filter(lambda l : l[-1] != 'No_Match', geocoded)
# geo_ids = [[match[0], ''.join(match[-4:])] for match in matched]

# with open('scrapes/geocoded_bk_kfc.csv', 'w') as f:
#     csv.writer(f).writerows(geo_ids)

# with open('scrapes/GeocodeResults_3.csv', 'r') as f:
#     geocoded = list(csv.reader(f))
# matched = filter(lambda l : l[-1] != 'No_Match', geocoded)
# geo_ids = [[match[0], ''.join(match[-4:])] for match in matched]
# with open('scrapes/geocoded_subway.csv', 'w') as f:
#     csv.writer(f).writerows(geo_ids)

with open('scrapes/GeocodeResults_mcdonalds_1.csv', 'r') as f:
    geocoded = list(csv.reader(f))
with open('scrapes/GeocodeResults_mcdonalds_2.csv', 'r') as f:
    geocoded += list(csv.reader(f))
matched = filter(lambda l : l[-1] != 'No_Match' and l[-1] != 'Tie', geocoded)
geo_ids = [[match[0], ''.join(match[-4:])] for match in matched]
with open('scrapes/geocoded_mcdonalds.csv', 'w') as f:
    csv.writer(f).writerows(geo_ids)
