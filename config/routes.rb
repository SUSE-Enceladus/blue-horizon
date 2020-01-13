# frozen_string_literal: true

Rails.application.routes.draw do
  # Welcome
  root to: 'welcome#index'
  get '/welcome', to: 'welcome#index'
  # switch paths
  get '/welcome/simple', to: 'welcome#simple', as: 'simple'
  get '/welcome/advanced', to: 'welcome#advanced', as: 'advanced'

  # Cluster size
  resource :cluster, only: [:show, :update]
  # Additional data
  resource :variables, only: [:show, :update]
  # Custom/Advanced
  resources :sources, except: [:show]
  # Show plan
  resource :plan, only: [:show]
  # Deploy
  resource :deploy, only: [:show]

  resource :deploy do
    get 'pre_deploy', on: :member
  end

  resource :deploy do
    get 'send_current_status', on: :member
  end

  resource :polling, only: [:show]

  # mock routes
  get '/download', to: 'welcome#index'
end
