Rails.application.routes.draw do
  root 'home#index'
  resources :posts
  devise_for :users
   # stripe listen --forward-to localhost:3000/stripe/webhooks
  post '/stripe/webhooks', to: 'stripe/webhooks#create'

  get "pricing", to: "stripe/checkout#pricing"

  post 'stripe/checkout', to: 'stripe/checkout#checkout'
  get 'stripe/checkout/new', to: 'stripe/checkout#new'

  get 'stripe/checkout/success', to: 'stripe/checkout#success'

  get 'stripe/checkout/cancel', to: 'stripe/checkout#cancel'

  post 'stripe/billing_portal', to: 'stripe/billing_portal#create'


end
