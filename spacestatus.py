import urllib.request, urllib.parse, urllib.error, json
url = "https://spaceapi.syn2cat.lu/status/json"
response = urllib.request.urlopen(url);
data = json.loads(response.read())
print(data["state"]["open"])
