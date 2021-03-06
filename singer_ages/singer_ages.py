import json
import re
import glob
import time
import pywikibot
import pdb
from pywikibot.data import api


billboard_dir = r'/mnt/c/Dropbox (Penn)/scripts/singer_ages/billboard/data/years/'

billboard_files = glob.glob(billboard_dir + '*.json')
data = []
for billboard_file in billboard_files:
    with open(billboard_file) as json_file:
        songs = json.load(json_file)
        for song in songs:
            data.append({'artist':song['artist'], 'title':song['title'], 'year':song['year']})
singers = [song['artist'] for song in data]
singers = {k:{} for k in set(singers)}


site = pywikibot.Site('wikidata', 'wikidata')
repo = site.data_repository()

singer = "Paul Young"
for singer in singers:
    try:
        print(singer)
        # print(len(singers[singer]))
        if len(singers[singer])>0:
            print('continuing...')
            continue
        # if singer=='Tremeloes':
        #     pdb.set_trace()
        wikidataEntries = api.Request(site=site, action='wbsearchentities',format='json', language='en', type='item', search=singer).submit()
        idx = 0
        if len(wikidataEntries)>1:
            idx = [i for i,e in enumerate(wikidataEntries['search']) if 'description' in e.keys() and re.search('musician|singer|artist',e['description'])]
            if len(idx) != 1:
                singers[singer] = {'search_id' : wikidataEntries['search'][0]['id']}
                continue
            idx = idx[0]
        id = wikidataEntries['search'][idx]['id']
        item = pywikibot.ItemPage(repo, id)
        item_dict = item.get()
        clm_dict = item_dict["claims"]
        clm_list = clm_dict["P569"]
        target = clm_list[0].getTarget()
        singers[singer]  = {'year':target.year, 'month':target.month}
        print(singers[singer])
        time.sleep(3)
    except:
        print('exception: '+singer)


# with open('birthdays.json', 'w') as f:
#     json.dump(singers, f)

# with open('billboard.json', 'w') as f:
#     json.dump(data, f)


for i in range(len(data)):
    if data[i]['artist'] in singers and 'year' in singers[data[i]['artist']]:
        data[i]['birthdate'] = singers[data[i]['artist']]['year']

data_complete = [song.values() for song in data if 'birthdate' in song]
with open('data.csv', 'wb') as f:
    csv.writer(f).writerows(list(data_complete))

# data[820,]
#           song         artist year birth.year age
# 820 Sweet Baby Stanley Clarke 1981       1898  83

## this should be Stanley Clarke the bassist, but there is a (visual) artist named Stanley Clarke that was chosen instead.

## https://www.wikidata.org/w/api.php?action=wbsearchentities&search=Stanley%20Clarke&language=en

# > data[which(data$age<2),]
#                         song     artist year birth.year age
# 896            All This Love    Debarge 1983       1990  -7
# 946         Time Will Reveal    Debarge 1984       1990  -6
# 962      Rhythm Of The Night    Debarge 1985       1990  -5
# 983  Who's Holding Donna Now    Debarge 1985       1990  -5
# 1375                 I'll Be Foxy Brown 1997       2000  -3
# 1481                Party Up        DMX 2000       2000   0
# >
## similar issue with "Michael Jackson", there are two artist/musicians by that name so the script picks neither. wikidata seems to sort the search hits in descending order of popularity, so here's another attemps choosing the first hit:

singers = [song['artist'] for song in data]
singers = {k:{} for k in set(singers)}

for singer in singers:
    try:
        print(singer)
        # print(len(singers[singer]))
        if len(singers[singer])>0:
            print('continuing...')
            continue
        # if singer=='Tremeloes':
        #     pdb.set_trace()
        wikidataEntries = api.Request(site=site, action='wbsearchentities',format='json', language='en', type='item', search=singer).submit()
        idx = 0
        # if len(wikidataEntries)>1:
        #     idx = [i for i,e in enumerate(wikidataEntries['search']) if 'description' in e.keys() and re.search('musician|singer|artist',e['description'])]
        #     if len(idx) != 1:
        #         singers[singer] = {'search_id' : wikidataEntries['search'][0]['id']}
        #         continue
        #     idx = idx[0]
        id = wikidataEntries['search'][0]['id']
        item = pywikibot.ItemPage(repo, id)
        item_dict = item.get()
        clm_dict = item_dict["claims"]
        clm_list = clm_dict["P569"]
        target = clm_list[0].getTarget()
        singers[singer]  = {'year':target.year, 'month':target.month}
        print(singers[singer])
        time.sleep(3)
    except:
        print('exception: '+singer)
