Spree::Core::Engine.routes.draw do
  resource :amazon_order, only: [], controller: "amazon" do
    member do
      get 'address'
      post 'payment'
      get 'delivery'
      post 'confirm'
    end
  end

  resources :amazon_order, only: [], controller: "amazon" do
    post 'complete'
  end

  post '/amazon_callback', to: 'amazon_callback#new'
  get '/amazon_callback', to: 'amazon_callback#new'

  namespace :admin do
    resource :amazon, only: [:edit, :update], controller: "amazon"
  end
end
