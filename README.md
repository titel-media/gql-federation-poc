# GraphQL Federation Proof-of-Concept
A simple prototype using Apollo GraphQL Federation to combine two small elixir Graphql services 

## Setup
We have 3 services. Start the elixir services first, then run the federator.
* `product_api`
    * `cd product_api && mix deps.get && iex -S mix`
    * runs on port `3010` by default (see `config/config.exs`)
    * example query:
```Graphql
query test {
  product: product(id: 1) {
    name
    brand
  }
```
* `user_api`
    * `cd user_api && mix deps.get && iex -S mix`
    * runs on port `3020` by default (see `config/config.exs`)
    * example query: 
```Graphql
query test {
  user: fetchUserById(id: 3) {
    email
  }
}
```
* `federator`
    * `cd federator && npm install && npm start server`
    * runs on port `4000` by default

## Try it out

Send this query to the federator:
```Graphql
query test {
  # from the user service
  user: fetchUserById(id: 2) {
    email
  }
  # from the product service
  product: product(id: 2) {
    name
    brand
  }
  # from both, using federation
  user_with_products: fetchUserById(id: 1) {
    products {
      name
      brand
      priceUSD
    }
    email
  }
}
```

You should see this response
```json
{
  "data": {
    "user": {
      "email": "kanye@highsnobiety.com"
    },
    "product": {
      "name": "Blue Hat",
      "brand": "Balenciaga"
    },
    "user_with_products": {
      "products": [
        {
          "name": "Red Belt",
          "brand": "Gucci",
          "priceUSD": 1000
        },
        {
          "name": "Blue Hat",
          "brand": "Balenciaga",
          "priceUSD": 2000
        },
        {
          "name": "Green Scarf",
          "brand": "Vetements",
          "priceUSD": 3000
        }
      ],
      "email": "virgil@highsnobiety.com"
    }
  }
}
```

## Read More:
[Federation Specs](https://www.apollographql.com/docs/apollo-server/federation/federation-spec/#schema-modifications-glossary)
