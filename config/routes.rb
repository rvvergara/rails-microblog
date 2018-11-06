Rails.application.routes.draw do
  get 'static/Pages'
  get 'static/home'
  get 'static/help'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "application#hello"
end
