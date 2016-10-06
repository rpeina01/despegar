# Despegar crawler

Crawler that obtains despegar.com prices from multiple trip dates

## Basic Usage:

```ruby
ruby get_trip_prices.rb -f FROM_CITY_CODE -t TO_CITY_CODE -d TRIP_DURATION_IN_DAYS
```

Where:
* FROM_CITY_CODE: Código correspondiente a la ciudad de inicio (e.g: SCL)
* TO_CITY_CODE: Código correspondiente a la ciudad de destino (e.g: MIA)
* TRIP_DURATION_IN_DAYS: Duración del viaje en días (e.g: 14)

## Examples:
Get prices from SCL to MIA for a 14 days trip
```ruby
ruby get_trip_prices.rb -f scl -t mia -d 14
```
