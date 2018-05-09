Rails.application.routes.draw do
  get 'home/index'
  root 'home#index'
  post 'tool/excel_splitter', as: 'excel_splitter'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
