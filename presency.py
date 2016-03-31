# this gives number of people present via spaceapi
# but if network down, this does not work
# better get data direct from pidor or peoplecounter
import urllib.request, urllib.parse, urllib.error, json
url = "https://spaceapi.syn2cat.lu/status/json"
response = urllib.request.urlopen(url);
data = json.loads(response.read())
print(data["sensors"]["people_now_present"][0]["value"])
