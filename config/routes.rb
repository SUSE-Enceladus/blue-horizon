Rails.application.routes.draw do
  # Welcome
  root to: 'welcome#index'
  get '/welcome', to: 'welcome#index'
  # Cluster size
  resource :cluster, only: [:show, :update]
  # Custom/Advanced
  resources :sources, except: [:show]

  # mock routes
  get '/framework', to: 'welcome#index'
  get '/plan', to: 'welcome#index'
  get '/deploy', to: 'welcome#index'
  get '/download', to: 'welcome#index'
end
