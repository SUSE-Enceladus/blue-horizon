# frozen_string_literal: true

Rails.application.routes.draw do
  # Welcome
  root to: redirect('/welcome')
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
  resource :plan, only: [:show, :update]
  # Deploy
  resource :deploy, only: [:show, :update, :create]

  resource :deploy do
    get 'send_current_status', on: :member
  end
  get '/wrapup', to: 'wrapup#index'
  get '/download', to: 'download#download'
end
