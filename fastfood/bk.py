import requests
from lxml import html
import time,random
import json,csv
import pdb

save_file = 'bk.json'
base = 'http://locations.bk.com/'
headers = {'User-agent':'Chrome/62.0.3202.89'}

tree = html.fromstring(requests.get(base, headers=headers).text)
state_links = [elt.attrib['href'] for elt in tree.xpath('//a[@class="c-directory-list-content-item-link"]')]

addresses = []

with open(save_file) as f:
    addresses = json.load(f)
state_links = state_links[(state_links.index('wa.html')+2):]
# state_links = state_links[state_links.index('ok.html'):]

for state_link in state_links:#state_link = state_links[0]

    tree = html.fromstring(requests.get(base + '/' + state_link, headers=headers).text)
    city_links = [elt.attrib['href'] for elt in tree.xpath('//div[@class="c-directory-list"]')[0].xpath('.//li[@class="c-directory-list-content-item"]/a')]

    for city_link in city_links:#city_link = city_links[0]

        tree = html.fromstring(requests.get(base + '/' + '/' + city_link, headers=headers).text)
        # addresses.append([elt.text_content() for elt in tree.xpath('//address[@class="c-address"]')])
        new_address = [', '.join([elt.text_content().strip() for elt in restaurant_rows.xpath('.//div[@class="c-AddressRow"]')]) for restaurant_rows in tree.xpath('//address[@class="c-address"]')]        
        # pdb.set_trace()
        addresses += new_address
        print('adding...')
        print(new_address)
        time.sleep(random.randint(1,10))

    with open(save_file, 'w') as f:
        json.dump(addresses,f)

## DC location added separately
addresses += ['191 Chappie James Blvd Sw Bolling, Washington, DC 20032']



aa = list(set(addresses))
with open('fastfood_addresses.csv', 'a') as f:
    writer = csv.writer(f)
    for address in aa:
        writer.writerow(['bk',address.encode('utf-8')])
