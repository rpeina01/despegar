# Despegar crawler

Crawler that obtains despegar.com prices from multiple trip dates

Basic Usage:

```shell
ruby get_trip_prices.rb -c CITY_CODE -d TRIP_DURATION_IN_DAYS
```

Where:
* CITY_CODE: Código correspondiente a la ciudad (e.g: MIA)
* TRIP_DURATION_IN_DAYS: Duración del viaje en días (e.g: 14)

Example:
```shell
ruby get_trip_prices.rb -c mia -d 14
```
