leakybucket_app
===============

Rack app to provide a leaky bucket service

API:

```
GET /create
GET /create?key=<bucket key>&limit=<limit>
```
Creates a new leaky bucket

```
GET /bucket?key=<bucket key>
```
Gets details for a specific bucket

```
GET /increment?key=<bucket key>
```
Increments the value

```
GET /decrement?key=<bucket key>
```
Decrements the value


All methods return the bucket with the bucket key provided. If no bucket key is provided, a new bucket is created
with a random key.

Return format:
```json
   {"key":"<a key>","value":<current value>,"leaking":<true or false>, "limit":<limit>}
   {"key":"1d6a4b51-b480-446b-8cb5-2bb4c6a1137f","value":3,"leaking":false, "limit":10}
```




