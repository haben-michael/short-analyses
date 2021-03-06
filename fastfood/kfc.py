import requests
from lxml import html
import time
import random
import json,csv
import pdb

save_file = 'kfc.json'
base = 'https://locations.kfc.com/'

tree = html.fromstring(requests.get(base).text)
state_links = [elt.attrib['href'] for elt in tree.xpath('//div[@class="Directory-content"]')[0].xpath('.//li[@class="Directory-listItem"]/a')]

addresses = []

for state_link in state_links:#state_link = state_links[0]

    tree = html.fromstring(requests.get(base + '/' + state_link).text)
    city_links = [elt.attrib['href'] for elt in tree.xpath('//div[@class="Directory-content"]')[0].xpath('.//li[@class="Directory-listItem"]/a')]

    for city_link in city_links:#city_link = city_links[0]

        tree = html.fromstring(requests.get(base + '/' + '/' + city_link).text)
        # addresses.append([elt.text_content() for elt in tree.xpath('//address[@class="c-address"]')])
        new_addresses = [', '.join(elt.text_content().strip() for elt in restaurant_rows.xpath('.//div[@class="c-AddressRow"]')) for restaurant_rows in tree.xpath('//address[@class="c-address"]')]
        addresses.append(new_addresses)
        # pdb.set_trace()
        print('adding...')
        print(new_addresses)
        time.sleep(random.randint(1,10))

    with open(save_file, 'w') as f:
        json.dump(addresses,f)

with open(save_file) as f:
    addresses = json.load(f)
aa = list(set([x for y in addresses for x in y]))
with open('fastfood_addresses.csv', 'a') as f:
    writer = csv.writer(f)
    for address in aa:
        writer.writerow(['kfc',address.encode('utf-8')])
