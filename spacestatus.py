import urllib, json
url = "https://spaceapi.syn2cat.lu/status/json"
response = urllib.urlopen(url);
data = json.loads(response.read())
print data["state"]["open"]
