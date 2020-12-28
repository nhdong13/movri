trackingStartedCheckout = (started_checkout_as_json) ->
  _learnq.push(["track", "Started Checkout",
    started_checkout_as_json
  ]);

window.KlaviyoTracking =
  trackingStartedCheckout: (started_checkout_as_json) ->
    $(document).ready ->
      trackingStartedCheckout(started_checkout_as_json)