import xmltodict
e = open('en-it.tmx', 'r').read()
result = xmltodict.parse(e)

def return_en_it_tuple(pairs):
    pp = pairs['tuv']
    res = {}
    for p in pp:
        res[p['@xml:lang']] = p['seg']
    return (res['en'], res['it'])

data = [return_en_it_tuple(pairs)
        for pairs in result['tmx']['body']['tu']]
    
