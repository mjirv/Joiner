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
  get '/join_dbs/new' => 'join_dbs#new'  
  get '/join_dbs/:id' => 'join_dbs#show', as: 'join_db'
  post '/join_dbs' => 'join_dbs#create'
  get '/join_dbs/:id/delete' => 'join_dbs#destroy', as: 'delete_join_db'

  #RemoteDb routes
  get 'remote_dbs/new' => 'remote_dbs#new'  
  get '/remote_dbs/:id' => 'remote_dbs#show'
  post '/remote_dbs' => 'remote_dbs#create'
  get '/remote_dbs/:id/delete' => 'remote_dbs#destroy', as: 'delete_remote_db'
end
