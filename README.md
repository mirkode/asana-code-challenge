# Coordinat0r - Code Challenge Project (WIP)

## Description
This is a little code challenge project I've built.
Main task of this mini app is to provide a super simple and light-weight server app that provides a "standardized" geolocation API.
The app is accessible via a token-authenticated GET request.
The token for now is hardcoded, but should be swapped if ever used in production or any other environment.

### Design Decisions
Some thoughts on this app:
Please bare with me as I had to keep the developing time on this little thing quite low.

#### Framework
To keep it light-weight, yet having some benefits of a framework Sinatra was chosen.
Rails would be way too blown up for such a simple little web app, so I decided that Sinatra has a perfect scope for this task.
Besides that I don't often get the chance to build something in Sinatra, so it is nice to dive into the differences from time to time.

#### Network
As a HTTP library I chose `HTTParty` over the built-in `Net::HTTP` library, because unfortunately `Net::HTTP` is way too cumbersome to use in my opinion.

#### Configuration
The configuration is mainly handled via ENV variables. I find this approach one of the easiest to handle as you don't need a deploy if one of those values change.
The `dotenv` gem is a nice and convenient way to include one or more configuration files (e.g. one per environment) containing all necessary info such as API keys.
Provider like Heroku make it easy to change ENV variables on the fly without fiddling with extra files.

#### Testing
Even though RSpec might be a little heavy for this app, I chose it mainly because tests can become very messy, very quickly.
So I find that RSpec and its matchers and structure is nicely readable.
And my experience with RSpec is higher than other test frameworks, such as e.g. Minitest.
Right now there are only `request specs` so far (as I considered them the most important).
But one or two unit tests will follow to make sure that the provider specific responses are parsed correctly and the API output is consistent.
Maybe also some basic integration tests for the demo app will follow up. But I think this is not really necessary.

#### Why jQuery?!
I would have loved to build this low-tech front-end in Vue with all the nice stuff that comes with it!
But that would have really been too much. So I decided to keep it oldschool.
Just plain and simple HTML, CSS and JavaScript/jQuery (for the ajaxy stuff).

#### Error handling
The API adapter has an own `GeoCodingError` class. It gets raised in two occasions:
Either when there are no results, or when there is a HTTP status code that is *neither* `200`, *nor* `291` (so e.g. `404`, `401`, etc.).
In case of no results being returned, the response JSON includes the name of the provider and the error message `No results.`.
In case of an errorneous HTTP status, the response JSON includes the `HTTP status code`, the `request path`, as well as the `response` from the external API.

#### Structure
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

The `app.rb` includes two routes. One is the simple API `GET` endpoint, the other one just shows the demo page (`index.html`)

## Set Up
1. Clone the directory
`git clone https://github.com/mirkode/asana-code-challenge.git`

2. `cd` into repository
`cd asana-code-challenge`

3. Copy .env.example to .env
`cp .env.example .env`

4. Modify `.env` file
`vim .env`

5. Insert all needed API endpoints, keys, and data _(more on this below)_
`DEFAULT` = Insert your desired default provider (for me that is Google)
e.g. `GOOGLE_API_KEY` = Your Google Maps API key

6. Start Up
Fire up the app in the `asana-code-challenge` directory by entering
`rackup -p 4567` (or any other port you need)

7. Access
In a browser open up `http://localhost:4567/`

## Request
The request itself is really simple. Two `GET` parameters can be given:
* `address`: This is the address string
* `provider`: This is one of multiple providers

## Response
You can have one out of multiple JSON responses.
The - hopefully - most common response is the

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
If you forget to append an address you will receive a `400 Bad Request`
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