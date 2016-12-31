Rails.application.routes.draw do
  root to: 'static#welcome'
  get '/about', to: 'static#about', as: 'about'
  get '/community-guidelines', to: 'static#community_guidelines', as: 'community_guidelines'
  get '/faq', to: 'static#faq', as: 'faq'
  get '/chat', to: 'chat#index', as: 'chat'
  post '/chat', to: 'chat#create'

  resources :topics

  mount ActionCable.server, at: '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
