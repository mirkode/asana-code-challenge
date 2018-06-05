# Coordinat0r - Code Challenge Project

## Description
This is a little code challenge project I've built.
Main task of this mini app is to provide a super simple and light-weight server app that provides a "standardized" geolocation API.
The app is accessible via a token-authenticated GET request.
The token for now is hardcoded, but should be swapped if ever used in production or any other environment.

## Set Up
1. Clone the directory
`git clone https://github.com/mirkode/asana-code-challenge.git`

2. `cd` into repository
`cd asana-code-challenge`

3. Copy .env.example to .env
`cp .env.example .env`

4. Modify `.env` file
`vim .env`

5. Insert all needed API endpotins, keys, and data _(more on this below)_
`DEFAULT` = Insert your desired default provider (for me that is Google)
e.g. `GOOGLE_API_KEY` = Your Google Maps API key

6. Start Up
Fire up the app in the `asana-code-challenge` directory by entering
`rackup -p 4567` (or any other port you need)

7. Access
In a browser open up `http://localhost:4567/test`

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
