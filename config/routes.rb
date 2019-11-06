# frozen_string_literal: true

Rails.application.routes.draw do
  # Welcome
  root to: 'welcome#index'
  get '/welcome', to: 'welcome#index'
  # Cluster size
  resource :cluster, only: [:show, :update]
  # Additional data
  resource :variables, only: [:show, :update]
  # Custom/Advanced
  resources :sources, except: [:show]

  # mock routes
  get '/plan', to: 'welcome#index'
  get '/deploy', to: 'welcome#index'
  get '/download', to: 'welcome#index'
end
