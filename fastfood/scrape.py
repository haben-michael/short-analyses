import requests
from lxml import html,etree
import time,random
import json,csv,os
import pdb

save_file = 'scrapes/mcdonalds.json'
base = 'https://www.hours-locations.com'
restaurant_link = '/mcdonalds'
headers = {'User-agent':'Chrome/62.0.3202.89'}

tree = html.fromstring(requests.get(base+restaurant_link, headers=headers).text)
state_links = [elt.attrib['href'] for elt in tree.xpath('//ol[@class="locations"]/li/a')]

if not os.path.exists(save_file):
    with open(save_file, 'w') as f:
        json.dump([],f)
    
with open(save_file, 'r') as f:
    addresses = json.load(f)
state_links = state_links[state_links.index('/mcdonalds/mi/'):]

for state_link in state_links:#state_link = state_links[0]

    state = state_link[-3:-1].upper()
    tree = html.fromstring(requests.get(base + state_link, headers=headers).text)
    city_links = [elt.attrib['href'] for elt in tree.xpath('//ol[@class="locations"]/li/a')]

    for city_link in city_links:#city_link = city_links[0]
        print city_link

        try:
            tree = html.fromstring(requests.get(base + city_link, headers=headers).text)
            if tree.xpath('//div[@id="store-intro"]'):
                addresses.append(tree.xpath('//div[@id="store-intro"]/h1')[0].text.strip())
            else:
                locations = etree.tostring(tree.xpath('//div[@id="content"]')[0]).split('<hr/>')
                [addresses.append(location.split('<br/>')[-3:-1] + [state]) for location in locations]
        except:
            pdb.set_trace()
        time.sleep(random.randint(1,10))

    with open(save_file, 'w') as f:
        json.dump(addresses,f)
    print addresses[-10:] 

# addresses = []
