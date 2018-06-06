# Coordinat0r - Code Challenge Project (WIP)

* [Description](#description)
* [Design Decisions](#design-decisions)
  * [Framework](#framework)
  * [Network](#network)
  * [Configuration](#configuration)
  * [Testing](#testing)
  * [Why jQuery?!](#why-jquery)
  * [Error Handling](#error-handling)
  * [Authorization](#authorization)
* [Structure](#structure)
  * [General](#general)
  * [Plugs](#plugs)
* [Set Up](#set-up)
* [Requests](#requests)
* [Responses](#responses)
  * [Success](#success)
  * [No Results](#no-results)
  * [Malformed Request](#malformed-request)
  * [Other](#other)

## Description
This is a little code challenge project I've built.  
The main task of this mini app is to run as a super simple and light-weight server app that provides a "standardized" geolocation API.
The app is accessible via a basic-authenticated GET request.  
The token credentials are hardcoded for now and for the sake of simplicity, but should be swapped if ever used in a production or any other environment other than locally.

## Design Decisions
Some thoughts on this app:  
Please bare with me as I had to keep the developing time on this little thing quite low.

### Framework
To keep it light-weight, yet having some benefits of a framework, Sinatra was chosen.  
Rails for example would be way too blown up for such a little web app, so I decided that Sinatra has a perfect scope for this task.  
Besides that I don't often get the chance to build something with Sinatra, so it is nice to dive into the differences from time to time.  

### Network
As an HTTP library I chose `HTTParty` over the built-in `Net::HTTP` library, because unfortunately `Net::HTTP` is way too cumbersome to use in my opinion.

### Configuration
The configuration is mainly handled via `ENV` variables. I find this approach one of the easiest to handle as you don't need a deploy if one of those values need to change.  
The `dotenv` gem is a nice and convenient way to include one or more configuration files (e.g. one per environment), containing all necessary info such as API keys.  
Providers like Heroku make it easy to change `ENV` variables on the fly without fiddling with extra files.

### Testing
Even though RSpec might be a little heavy for this app, I chose it mainly because tests can become very unreadable, very quickly.  
So I find that RSpec and its matchers keep the spec structure nicely readable.  
And my experience level with RSpec is higher than with other test frameworks, such as e.g. Minitest.  
Right now there are only `request specs` so far (as I considered them the most important).  
But one or two unit tests might follow to make sure that the provider specific responses are parsed correctly and the API output is consistent.  
Maybe also some basic integration tests for the demo app will follow up.

### Why jQuery?!
I would have loved to build this low-tech front-end in Vue with all the nice stuff that comes with it!  
But that would have really been too much. So I decided to keep it oldschool.  
Just plain and simple HTML, CSS and JavaScript/jQuery (for the ajaxy stuff).  

### Error handling
The API adapter has an own `GeoCodingError` class. It gets raised on two occasions:  
Either when there are no results, or when there is a HTTP status code that is *neither* `200`, *nor* `291` (so e.g. `404`, `401`, etc.).  
In case of no results being returned, the response JSON includes the name of the provider and the error message `No results.`.  
In case of an errorneous HTTP status, the response JSON includes the `HTTP status code`, the `request path`, as well as the `response` from the external API.

### Authorization
To start with, I included some very basic authentication. First I was thinking of JWT and such, but that would have maybe gone beyond the scope.  
So, right now there is a username and password hardcoded in the demo app, which gets encoded in a base64 ASCII string. This string is then used as a token and verified on the backend side to  
a.) exist  
b.) match the credentials from the front-end.  
In production I would probably generate a proper JWT for each app that wants to access the API and then match it against the records in the database for that particular token.

## Structure
The app consists of multiple files.  
```
├- app.rb - (the main entry point)
├- config.ru 
├- Gemfile
├- Gemfile.lock
├- README.md - (the file you're just reading)
└- adapters
│  ├- adapter.rb - (connects to the external API and retrieves the 'raw' response data)
│  └- plugs - (a folder of provider specific logic)
│     ├- bing.rb - (Bing-specific endpoint and stub for response parsing)
│     ├- google.rb - (Google Maps-specific endpoint and response parsing)
│     └- osm.rb - (OpenStreetMaps-specific endpoint and response parsing)
├- public
|  └- index.html (the demo page)
└- spec
   └- ... (test-suite)
```

### General
The `app.rb` includes two routes. One is the simple API `GET` endpoint, the other one just shows the static demo page (`index.html`).  
The app itself is structure in such a way so multiple external API providers can be used.  
The `Adapter` object (`adapter.rb`) handles all requests regardless of the provider. It gets initialized with a `query` (e.g. the address) and an optional `provider` (e.g. Google). If no provider is passed in, the default provider, as specified in the `.env` file, will be used.  
The `Adapter` class includes `HTTParty` and inherits its methods. That allows us to call `get(url)` in the `Adapter` class.  
After initialization we call `.get_coordinates` on the `Adapter` object. This causes the object to instantiate a new provider-based `Plug` object (with the given provider name) and retrieves the provider specific endpoint.  
_Please note:_ The provider name in the `.env` file must match case sensitively the name of the respective `'Plug'` class (more on that below).  
Having retrieved the endpoint, the `Adapter` object now invokes the internal `get` method, which again invokes the internal `api_call` method.  
The `get` method returns two values: the `response` and wether the request was a `success` or not.  
If it was successful, the response is checked for any results. If there aren't any, a `GeoCodingError` is raised with the error message `no results`. This handles invalid and/or non-existant addresses.  
If there are results, those get parsed in a provider-specific and returned in a standardized manner, because obviously each provider responses look differently.  
This results in a consistent API output, regardless of which provider is being used in the end.  
The `GET` request itself is quite straight forward. As mentioned before the `get` method calls the internal `api_call` method. This has the advantage that other requests, such as `PUT` or `POST` can also be used without the need to copy the `HTTParty` request functionality.   
The `api_call` uses the respective `HTTParty` method to connect to the external API endpoint (as passed through the provider-specific `Plug`).  
Unless the returned HTTP status code from `HTTParty` does not match `200` a `GeoCodingError` is raised.  
If it matches the `success` status code, the status code, as well as the raw response, gets returned as the `response` variable by the `get` method.

### Plugs
I mentioned the `Plugs` twice in the section above.  
A `Plug` is serving the provider-specific logic and handles the authorization, endpoint construction, and response parsing for every needed API endpoint.  
Those are located in the `plugs` folder within the `adapters` folder.  
If you would need a new external API endpoint three methods are mandatory:  
1. `endpoint`: here you would need to create the endpoint URL as given by the provider (the return value would be something like "https://maps.googleapis.com/maps/api/geocode/json?address=SEARCH_QUERY&key=GOOGLE_API_KEY").  
2. `has_no_results?(response)`: here the response gets checked if it has any results. This needs to be adjusted to the API response of the external provider and return either `true|false`.  
3. `parse_response(response)`: in this method the response needs to be parsed and a standardized JSON needs to be returned. Please see the format of the JSON below:

```javascript
{
  'latitude': 52.0000000,
  'longitude': 13.000000,
  'formatted': '<the formatted address>',
  'type': '<the location type (e.g. recreational)>'
}
```

In order to use a `plug` all that needs to be done is to require it in the `adapter.rb` file (e.g. `require plugs/google`) and then be either passed as a `GET` param (e.g. `/search?address=xyz&provider=OSM`, or set as a default in the `.env` file (resp. in the specific `ENV` variable called `DEFAULT_PROVIDER`).  
Even if there is a use case to try and find really every address/location by using multiple providers, a loop over all those providers (e.g. using something like `Threads` and `Mutex` or so) would be also possible in the `get_coordinates` method. Instead of firing one `GET` request to one provider, one could loop over all providers, fire a `GET` request, parse the response, add it to the locations and then, when all providers have been accessed, sort the `locations` array and remove possible duplicates.

## Set Up
1. Clone the directory.  
   `git clone https://github.com/mirkode/asana-code-challenge.git`

2. `cd` into repository.  
   `cd asana-code-challenge`

3. Copy `.env.example` to `.env`.  
   `cp .env.example .env`

4. Modify `.env` file.  
   `vim .env`

5. Insert all needed API endpoints, keys, and data _(more on this below)_.  
   `DEFAULT` = Insert your desired default provider (for me that is Google).  
   e.g. `GOOGLE_API_KEY` = Your Google Maps API key

6. Start Up.  
   Fire up the app in the `asana-code-challenge` directory by entering
   `rackup -p 4567` (or any other port you need)

7. Add Google Maps API key to `index.html`.  
   Scroll to the bottom to the `index.html` page or search for `<!-- ADD GOOGLE MAPS API KEY HERe -->`.  
   Replace `YOUR API KEY HERE` with your Google Maps API key, uncomment the script block and save the file.  
   In case you have forgotten this, there will be a little alert popping up.  
   As this is an acceptable solution if this app would be on production, please also delete the following lines:

   ```javascript
   153   // Just a quickfix for development only.
   154   // TODO: remove
   155   setTimeout(function () {
   156     if (typeof(map) === 'undefined') {
   157       alert('Cannot load the map.\nDid you forget to set the API key in the index.html?\nPlease add it, otherwise the app won\'t function properly.');
   158     }
   159   }, 500);
   ```

8. Access.  
   In a browser open up `http://localhost:4567/`

## Requests
The request itself is really simple. Two `GET` parameters can be given:
* `address`: This is the address string
* `provider`: This is one of multiple providers

## Responses
You can have one out of multiple JSON responses.  

### Success
```javascript
{
  "query": "Checkpoint Charlie",
  "coordinates": [
  {     
    "latitude": 52.5075459,
    "longitude": 13.3903685,
    "formatted": "Friedrichstraße 43-45, 10969 Berlin, Deutschland"
  },
  errors: []
}
```

### No Results
```javascript
{
    "query": "somethingterriblyinvalid",
    "coordinates": [],
    "errors": [
        {
            "provider": "Google",
            "message": "No results"
        }
    ]
}
```

### Malformed Request
If you forget to append an address you will receive a `400 Bad Request`.  
```javascript
{
  "errors": [
    {
      "message": "Please provide a geocodable search query (e.g. an address)"
    }
  ]
}
```

### Other
All other errors, when happening on the external API side, should be looped through to the front-end via the `GeoCodingError`.  
The error message follows the standard format above (ideally including on which provider's API it occurred).  
```javascript
{
  "errors": [
    {
      "provider": "PROVIDER_NAME",
      "errors": [{"message": "ERROR_MESSAGE"}]
    }
  ]
}
```