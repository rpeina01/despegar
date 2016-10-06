# Despegar crawler

Crawler that obtains despegar.com lowest prices from multiple trip dates

## Table of contents
- [Description](https://github.com/giovannibenussi/despegar#description)
- [Basic Usage](https://github.com/giovannibenussi/despegar#basic-usage)
- [Examples](https://github.com/giovannibenussi/despegar#examples)

## Description
Script to obtain the lowest pricest from despegar.com website's. You can select any origin and destination city to trip and also a duration in days from your trip (including a margin from this).

## Basic Usage:

```ruby
ruby get_trip_prices.rb -f FROM_CITY_CODE -t TO_CITY_CODE -d TRIP_DURATION_IN_DAYS
```

Where:
* FROM_CITY_CODE: [Short code](https://github.com/giovannibenussi/despegar/blob/master/city_codes.md) from origin city (e.g: SCL)
* TO_CITY_CODE: [Short code](https://github.com/giovannibenussi/despegar/blob/master/city_codes.md) from destination city (e.g: MIA)
* TRIP_DURATION_IN_DAYS: Duración del viaje en días (e.g: 14)

## Examples:
Get prices from SCL to MIA for a 14 days trip
```ruby
ruby get_trip_prices.rb -f scl -t mia -d 14
```
