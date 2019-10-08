Rails.application.routes.draw do
  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # mock routes
  get '/welcome', to: 'welcome#index'
  get '/cluster', to: 'welcome#index'
  get '/framework', to: 'welcome#index'
  get '/advanced', to: 'welcome#index'
  get '/plan', to: 'welcome#index'
  get '/deploy', to: 'welcome#index'
  get '/download', to: 'welcome#index'
end
