# ChargifyClient

A client for interacting with Chargify (https://reference.chargify.com/v1/basics/introduction).

## The basics

ChargifyClient was created to support Ruby applications that interact with multiple
Chargify "Sites". It uses a simple approach:
> A **Client** provices **Resources** that return **Objects**

### Resources
At version 0.0.1, only a portion of the Chargify API is covered. However, Resources that exist generally support:
- find_all(options = {})
- find_by_id(id)
- find_by_reference(handle)
- create(options)

Resource methods return Objects of the same type. For example `client.subscriptions.find_all()` returns an array of Subscription Objects.
Some Resources do not support all calls (either because the API makes them unavailable, or because coding is incomplete) and will raise a ChargifyClient::ResponseError.

### Objects
Resources return Objects which contain data retrieved from Chargify. For example, a Subscription will respond to `balance_in_cents` and `snap_day`, while a Customer will responds to `first_name` and `email`. Objects may contain nested Objects, as is the case with `subscription.customer` and `component.product_family`.

While it is permissible for Resources to provide type specific calls, Objects seem a better way to expose functionality. Consider the following methods available through Objects:

- Subscription.apply_service_credit
- Component.add_usage

Again, Resources could have exposed the endpoints backing these methods. However, making them available through Objects feels more natural and "Rubyish" (in the authors opinion).


## Usage

Instantiate a Client:

```
client = ChargifyClient.new(api_key: <your api_key>, subdomain: <your subdomain>)
```

Use the client to interact with Chargify endpoints:
```
subscriptions = client.subscriptions.find_all
```

You may wish to create a module to hold all of your clients as singletons:
```
module MyChargifyClients
  def acme
    @acme ||= ChargifyClient.new(api_key: "acme_key", subdomain: "acme_subdomain")
  end
  def other
    @other ||= ChargifyClient.new(api_key: "other_key", subdomain: "other_subdomain")
  end
end
```

Then you can use these objects as you see fit:
```
acme_subscriptions = MyChargifyClients.acme.subscriptions.find_all
other_customers = MyChargifyClients.other.customers.find_all
```

## Installation

TBD

## Development

To add support for a new endpoint, add these 4 files:
1. lib/chargify_client/resources/NEW_RESOURCES
2. lib/chargify_client/objects/NEW_OBJECT
3. spec/chargify_client/resources/NEW_RESOURCES_SPEC
4. spec/chargify_client/objects/NEW_OBJECT_SPEC
