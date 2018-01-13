Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/' => 'users#show'

  # these routes are for showing users a login form, logging them in, and logging them out.
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # JoinDb routes
  get '/joindb/:id' => 'join_db#show'
  get '/joindb/new' => 'join_db#new'
  post '/joindb' => 'join_db#create'

  #RemoteDb routes
  get '/remotedb/:id' => 'remote_db#show'
  get 'remotedb/new' => 'remote_db#new'
  post '/remotedb' => 'remote_db#new'
end
