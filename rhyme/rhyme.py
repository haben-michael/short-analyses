# https://www.garysieling.com/blog/rhyming-with-nlp-and-shakespeare
# internal rhymes

from nltk.corpus import cmudict
from nltk.tokenize import wordpunct_tokenize
import re
from urllib.request import urlopen
from lxml import etree
import os, time, random
import csv, json
import collections

ARTIST_LINKS_FILE = 'd:/scrapes/rhyme/artist_links.json'
SCRAPE_DIR = 'd:/scrapes/rhyme/'
BASE_URL = 'https://www.azlyrics.com/'
PUNCT = set(['.', ',', '!', ':', ';'])

# sonnet = ['O thou, my lovely boy, who in thy power', \
#    'Dost hold Time\'s fickle glass, his sickle, hour;', \
#    'Who hast by waning grown, and therein showst', \
#    'Thy lovers withering as thy sweet self growst;', \
#    'If Nature, sovereign mistress over wrack,', \
#    'As thou goest onwards, still will pluck thee back,', \
#    'She keeps thee to this purpose, that her skill', \
#    'May time disgrace and wretched minutes kill.', \
#    'Yet fear her, O thou minion of her pleasure!', \
#    'She may detain, but not still keep, her treasure:', \
#    'Her audit, though delayed, answered must be,', \
#    'And her quietus is to render thee.']

# lines = sonnet
# tokens = [wordpunct_tokenize(s) for s in lines]
# lines = [ [w for w in sentence if w not in PUNCT ] for sentence in tokens]
# print(count_matches(lines[4], lines[5]))
# for i in range(len(lines)-1):
#     print(count_matches(lines[i],lines[i+1]))


from nltk.corpus import cmudict
cd = cmudict.dict()


def count_matches(tokens_1, tokens_2):
    phonemes_list_1 = [cd.get(token, [[None]])[0] for token in tokens_1]
    phonemes_list_2 = [cd.get(token, [[None]])[0] for token in tokens_2]
    phonemes_1 = [x for y in phonemes_list_1 for x in y]
    phonemes_2 = [x for y in phonemes_list_2 for x in y]
    # phonemes_1 = [re.sub('0-9','',phoneme) for phoneme in phonemes_1 if phoneme]
    # phonemes_2 = [re.sub('0-9','',phoneme) for phoneme in phonemes_2 if phoneme]
    match_len = 0
    while match_len < min(len(phonemes_1), len(phonemes_2)) and phonemes_1[-(match_len + 1)] == phonemes_2[-(match_len + 1)] and phonemes_1[-(match_len + 1)] is not None:
        match_len += 1

    phonemes_added = 0
    [match_1, match_2] = [[], []]
    [idx_1, idx_2] = [len(phonemes_list_1) - 1, len(phonemes_list_2) - 1]
    while phonemes_added < match_len:
        match_1 = [tokens_1[idx_1]] + match_1
        phonemes_added += len(phonemes_list_1[idx_1])
        idx_1 -= 1
        match_2 = [tokens_2[idx_2]] + match_2
        phonemes_added += len(phonemes_list_2[idx_2])
        idx_2 -= 1

    # matches = []
    # if match_len > 0:
    #     matches = phonemes_1[-match_len:]
    return((match_len, match_1, match_2))


## run once--read in relative urls of artist pages
# alphabet = [chr(i) for i in range(ord('a'), ord('z') + 1)]

# artist_links = []
# for letter in alphabet:
#     url = BASE_URL + letter + '.html'
#     html_str = urlopen(url).read()
#     tree = etree.HTML(html_str)
#     link_columns = tree.xpath('//div[contains(@class,"artist-col")]')
#     links = [column.xpath('./a/@href') for column in link_columns]
#     links = [x for y in links for x in y]
#     artist_links = artist_links + links
#     time.sleep(abs(random.normalvariate(0, 25)))

# with open(ARTIST_LINKS_FILE,'w') as f: f.write(json.dumps(artist_links))

# def get_song_links(artist_link, save=True):
#     save_file = SCRAPE_DIR + 'song_links' + os.sep + os.path.split(artist_link)[-1][0:-4] + 'txt'
#     if os.path.exists(save_file):
#         with open(save_file, 'r') as f:
#             song_links = f.read().splitlines()
#     else:
#         artist_link = BASE_URL + artist_link
#         html_str = urlopen(artist_link).read()
#         tree = etree.HTML(html_str)
#         links = tree.xpath('//a/@href')
#         link_re = re.compile(r'../lyrics/')
#         song_links = list(filter(link_re.search, links))
#         song_links = [re.sub('\.\./', '', link) for link in song_links]

#         with open(save_file, 'w') as f:
#             f.write('\n'.join(song_links))

#     return(song_links)


# def get_lyrics(song_link, save=True):
#     relative_path = song_link
#     save_file = SCRAPE_DIR + relative_path[0:-4] + 'txt'

#     if os.path.exists(save_file):
#         with open(save_file, 'r') as f:
#             lyrics = f.read().splitlines()
#     else:
#         song_link = BASE_URL + song_links[3]
#         html_str = urlopen(song_link).read()
#         tree = etree.HTML(html_str)
#         div = tree.xpath('/html/body/div[3]/div/div[2]/div[5]')
#         lyrics = div[0].xpath('.//br/following-sibling::text()')
#         lyrics = [line.strip() for line in lyrics]

#         (save_dir, _) = os.path.split(relative_path)
#         if not os.path.exists(SCRAPE_DIR + save_dir):
#             os.makedirs(SCRAPE_DIR + save_dir)

#         with open(save_file, 'w') as f:
#             f.write('\n'.join(lyrics))

#     tokens = [wordpunct_tokenize(s) for s in lyrics]
#     tokens = [ [w for w in sentence if w not in PUNCT ] for sentence in tokens]

#     return((lyrics, tokens))


# with open(ARTIST_LINKS_FILE, 'r') as f:
#     artist_links = json.loads(f.read())

# # song_links = get_song_links(artist_links[5])
# # (lines, tokens) = get_lyrics(song_links[0])
# # for i in range(len(tokens)-1):
# #     print(count_matches(tokens[i],tokens[i+1]))



# for i in range(500):
#     try:
#         print('.')
#         artist_link = random.choice(artist_links)
#         song_links = get_song_links(artist_link)
#         get_lyrics(random.choice(song_links))
#         time.sleep(abs(random.normalvariate(0, 25)))
#     except:
#         pass


## 1. compute most common rhymes
## using kaggle data set (rather than azlyrics)
with open('d:/scrapes/rhyme/songdata.csv') as f:
    songdata = [{k: v for k, v in row.items()}
                for row in csv.DictReader(f, skipinitialspace=True)]

songs = [song['text'].split('\n') for song in songdata]
lens = [len(song) for song in songs]
total_lines = sum(lens)

## 1a. all rhymes
matches = []
for song in songdata:
    lyrics = song['text'].split('\n')
    tokens = [wordpunct_tokenize(s) for s in lyrics]
    tokens = [ [w for w in sentence if w not in PUNCT ] for sentence in tokens]
    for i in range(len(tokens)-1):
        match = count_matches(tokens[i],tokens[i+1])
        if match[0] is not 0:
            # matches.append(tuple(sorted((match[1][0],match[2][0]))))
            matches.append(tuple(sorted((' '.join(match[1]),' '.join(match[2])))))

counter = collections.Counter(matches)
out = counter.most_common(50)
out = [', '.join(['{0:.3}'.format(o[1]/total_lines*1e4),o[0][0],o[0][1]]) for o in out]
with open('120117a.txt', 'w') as f:
    for item in out:
        f.write('%s\n' % item)

# ## 1b. removing duplicate-word rhymes
diff_matches = [tuple(m) for m in matches if m[0] != m[1]]
counter = collections.Counter(diff_matches)
out = counter.most_common(50)
out = [', '.join(['{0:.3}'.format(o[1]/total_lines*1e4),o[0][0],o[0][1]]) for o in out]
with open('120117b.txt', 'w') as f:
    for item in out:
        f.write('%s\n' % item)

## 1c. limiting by length

long_matches = [tuple(m) for m in matches if (len(m[0].split(' '))>1 or len(m[1].split(' '))>1) and m[0] != m[1]]
counter = collections.Counter(long_matches)
counter.most_common(30)
out = counter.most_common(50)
out = [', '.join(['{0:.3}'.format(o[1]/total_lines*1e4),o[0][0],o[0][1]]) for o in out]
with open('120117c.txt', 'w') as f:
    for item in out:
        f.write('%s\n' % item)
