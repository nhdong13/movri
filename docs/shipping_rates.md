1. This task requires calculating the shipping cost for a listing on the website, to calculate the shipping cost of the current app, we use `postmen.com`

2. The sample account for test:
`duynmdev92@gmail.com / 1234rfvgy7890`

3. The important information needs to run postmen in our project:

- `postmen_api_key` for now in our project using `test_postmen_api_key` for test, we need to replace it by the real production key.

- `shipper_id` id for service delivery (e.g: Fedex, UPS...), to get `shipper_id` we need to come the postmen.com and register what service we'd like to use in app. For now, the sample account just only use fedex_shipper_id (variable name: `test_fedex_shipper_id`).

- The source code for calculation shipping rates at: `app/services/shipping_rates_service.rb`

- The references for how to use postmen:
https://secure.postmen.com/explorer/sandbox/calculate-rates
https://docs.postmen.com/ups.html?sdk=ruby#rates-calculate-rates

- Task-related:
https://trello.com/c/Po8KgCgK/27-can-not-estimate-shipping-price-calculation-on-product-page
