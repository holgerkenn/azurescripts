import urllib
import json
import time
import math
import sys,argparse

#add your config here or provide it via command line arguments
url = 'http://<yourwebsite>.azurewebsites.net/masterwrite.php'
token = '<yourtoken>'
sensorname = '<yoursensorname>'
master = '<masterkey as returned by the open.php API>'
latitude='52.532522'
longitude='13.345000'
altitude='34'
imageurl=''

def main():

    if verbose: 
        print('MasterWrite')
        print('URL:',url)
        print('token:',token)
        print('sensorname:',sensorname)
        print('master:',master)
        print('image url:',imageurl)

    valuestruct = {
        'name':sensorname,
        'type':'imagesensor',
        'version':'1.0',
        'latitude':latitude,
        'longitude':longitude,
        'altitude':altitude,
        'timestamp':math.trunc(time.time()),
        'imageurl':imageurl
        }

    valuejson = json.dumps(valuestruct)

    params = urllib.urlencode({
	    'p': sensorname,
	    't': token,
        'j':'1',
	    'm': master,
        'mo' : valuejson
    })

    print valuejson

    print params

    data = urllib.urlopen(url+"?%s" % params).read()

    print data


if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--url')
    parser.add_argument('-t', '--token')
    parser.add_argument('-s', '--sensorname')
    parser.add_argument('-m', '--master')
    parser.add_argument('-b', '--latitude')
    parser.add_argument('-l', '--longitude')
    parser.add_argument('-a', '--longitude')
    parser.add_argument('-v', dest='verbose', action='store_true')
    parser.add_argument('imageurl',metavar='<imageurl>',help='url of image');
    args = parser.parse_args()
    if args.url : url = args.url
    if args.token : token = args.token
    if args.sensorname : sensorname = args.sensorname
    if args.master : master = args.master
    if args.latitude : latitude = args.latitude
    if args.longitude : longitude = args.longitude
    if args.altitude : longitude = args.altitude
    imageurl = args.imageurl
    verbose=args.verbose
    main()
