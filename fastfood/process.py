# import json
# import csv
# import os
# from lxml import html

# with open('fastfood_addresses.csv','r') as f:
#     addresses = list(csv.reader(f))

# formatted = []
# for j in range(len(addresses[:])):
#     address = addresses[j][1].split(', ')
#     formatted.append([str(j)] + address[:2] + address[2].split(' '))

# with open('census_batch.csv', 'w') as f:
#     writer = csv.writer(f)
#     for address in formatted:
#         writer.writerow(address)
    

# ## bk

# import json
# import csv
# import os
# from lxml import html
# # dd = json.loads()

# json_files = os.listdir('./bk')
# json_files = filter(lambda s: s.endswith('JSON'),json_files)

# for json_file in json_files:
#     print(json_file)
#     with open('bk/'+json_file) as f:
#         pages = json.load(f)

#     addresses = {}
#     for page in pages:
#         # page = pages[0]
#         tree = html.fromstring(page)
#         locations = tree.xpath('//article')
#         for location in locations:
#             # location = locations[0]
#             id = location.xpath('.//a[@class="Teaser-titleLink"]')[0].attrib['href']
#             address = ''.join(location.xpath('.//address')[0].xpath('.//text()'))
#             addresses[id] = address

#     writer = csv.writer(open('bk.csv','wb'))
#     for id in addresses:
#         # print(id,addresses[id])
#         writer.writerow([id,addresses[id].encode('utf-8')])



        

# ## kfc

# import json
# import csv
# import os
# from lxml import html
# # dd = json.loads()

# json_files = os.listdir('./kfc')
# json_files = filter(lambda s: s.endswith('JSON'),json_files)

# for json_file in json_files:
#     print(json_file)
#     with open('kfc/'+json_file) as f:
#         pages = json.load(f)

#     addresses = {}
#     for page in pages:
#         # page = pages[0]
#         tree = html.fromstring(page)
#         # pdb.set_trace()
#         locations = tree.xpath('//li')
#         for location in locations:
#             # location = locations[0]
#             id = location.attrib['id']#location.xpath('.//a[@class="Teaser-titleLink"]')[0].attrib['href']
#             address = ''.join(location.xpath('.//address')[0].xpath('.//text()'))
#             addresses[id] = address

#     writer = csv.writer(open('kfc.csv','wb'))
#     for id in addresses:
#         # print(id,addresses[id])
#         writer.writerow([id,addresses[id].encode('utf-8')])



## subway

# import json
# import csv
# import os
# import pdb
# from lxml import html
# # dd = json.loads()

# json_files = os.listdir('./subway')
# json_files = filter(lambda s: s.endswith('JSON'),json_files)

# with open('scrapes/subway.csv','w') as f:
#     pass

# for json_file in json_files:
#     print(json_file)
#     with open('subway/'+json_file) as f:
#         pages = json.load(f)

#     addresses = {}
#     for page in pages:
#         # page = pages[0]
#         if len(page)==0:
#             continue
#         tree = html.fromstring(page)
#         # pdb.set_trace()
#         locations = tree.xpath('./div[contains(@class,"location")]')
#         for location in locations:
#             # location = locations[0]
#             id = location.attrib['data-id']
#             # pdb.set_trace()
#             # address = ''.join(location.xpath('.//div[@class=locatorAddress]')[0].xpath('.//text()'))
#             # address = ', '.join([''.join([s.strip() for s in elt.xpath('.//text()')]) for elt in location.xpath('.//div[contains(@class,"Address")]')])
#             address = location.xpath('.//div[contains(@class,"MainAddress")]')[0].text_content().strip()
#             country = location.xpath('.//div[contains(text(),"USA")]')
#             if len(country)==0: ## some foreign countries somehow end up in results eg "Avenida Rivadavia 6249" location
#                 continue
#             # if len(location.xpath('.//div[contains(text(),"US")]'))==0:
#             #     pdb.set_trace()
#             address += ', ' + country[0].text
#             # print(address)
#             addresses[id] = address

#     writer = csv.writer(open('scrapes/subway.csv','a'))
#     for id in addresses:
#         # print(id,addresses[id])
#         writer.writerow([id,addresses[id].encode('utf-8')])

# ## generate batch file for census geocoder
# with open('scrapes/subway.csv','r') as f:
#     locations = list(csv.reader(f))
# locations = locations[1:]
# locations = [location[0] + ', ' + ', '.join(location[1].split(', ')[:-2]) + ', ' + ', '.join(location[1].split(', ')[-2].split(' ')) for location in locations]
# with open('scrapes/census_batch_subway.csv','w') as f:
#     f.write('\n'.join(locations))


## mcdonalds/location-hours
import json
restaurant_name = 'mcdonalds'
save_file = 'scrapes/'+restaurant_name+'.json'

with open(save_file,'r') as f:
    addresses = json.load(f)

formatted = []

for i,address in enumerate(addresses):
    try:
        if type(address)==list:
            address = [s.replace('&#13;\n','') for s in address]
            # pdb.set_trace()
            formatted.append(','.join([str(i)]+[address[0]] + [address[1].split(' - ')[0]] + [address[2]] + [address[1].split(' - ')[1]]))
        else:
            formatted.append(str(i)+address.replace("McDonald's",''))
    except:
        print 'skipping ' + str(address)

with open('scrapes/census_batch_'+restaurant_name+'.csv','w') as f:
    f.write('\n'.join(formatted))
