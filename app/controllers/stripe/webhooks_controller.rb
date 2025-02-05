class Stripe::WebhooksController < ApplicationController
	skip_before_action :verify_authenticity_token

  def create

  # Replace this endpoint secret with your endpoint's unique secret
  # If you are testing with the CLI, find the secret by running 'stripe listen'
  # If you are using an endpoint defined with the API or dashboard, look in your webhook settings
  # at https://dashboard.stripe.com/webhooks
  webhook_secret = 'whsec_53cd861635f0395742b5293ec23b1b244e44c3587044fc17f9be3e9b8c3af8f6'
  payload = request.body.read
  if !webhook_secret.empty?
    # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, webhook_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts '⚠️  Webhook signature verification failed.'
      status 400
      return
    end
  else
    data = JSON.parse(payload, symbolize_names: true)
    event = Stripe::Event.construct_from(data)
  end
  # Get the type of webhook event sent - used to check the status of PaymentIntents.
  event_type = event['type']
  data = event['data']
  data_object = data['object']

  case event.type
  when 'customer.created'
  	customer = event.data.object
  	user = User.find_by(email: customer.email)
  	user.update(stripe_customer_id: customer.id)
  when event.type == 'customer.subscription.deleted', 'customer.subscription.updated', 'customer.subscription.created'
  	 subscription = event.data.object
  	 # debugger
      user = User.find_by(stripe_customer_id: subscription.customer)
      user.update(
        plan: subscription.items.data[0].price.recurring.interval,
        subscription_status: subscription.status,
        subscription_ends_at: Time.at(subscription.current_period_end).to_datetime
        )
  end

  render json: { message: 'success' }
  end
end
