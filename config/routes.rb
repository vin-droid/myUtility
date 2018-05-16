Rails.application.routes.draw do
	require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
  get 'home/index'
  root 'home#index'
  post 'tool/excel_splitter', as: 'excel_splitter'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
