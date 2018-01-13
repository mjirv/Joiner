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
  get '/joindb/:id' => 'join_dbs#show'
  get '/joindb/new' => 'join_dbs#new'
  post '/joindb' => 'join_dbs#create'
  delete '/joindb/:id' => 'join_dbs#destroy'

  #RemoteDb routes
  get '/remotedb/:id' => 'remote_dbs#show'
  get 'remotedb/new' => 'remote_dbs#new'
  post '/remotedb' => 'remote_dbs#new'
  delete '/remotedb/:id' => 'remote_dbs#destroy'
end
