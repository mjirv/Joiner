Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/signup' => 'users#new'
  #post '/users' => 'users#create'
  patch '/users/:id' => 'users#update', as: 'user'
  get '/' => 'users#show'
  get '/confirm_email.:token' => 'users#confirm_email', as: 'confirm_email_user'
  get '/reset_password/:token' => 'users#reset_password', as: 'reset_password'

  # these routes are for showing users a login form, logging them in, and logging them out.
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # JoinDb routes
  get '/join_dbs/new' => 'join_dbs#new'  
  get '/join_dbs/:id' => 'join_dbs#show', as: 'join_db'
  post '/join_dbs' => 'join_dbs#create'
  get '/join_dbs/:id/edit' => 'join_dbs#edit', as: 'edit_join_db'
  patch '/join_dbs/:id' => 'join_dbs#update'
  get '/join_dbs/:id/delete' => 'join_dbs#destroy', as: 'delete_join_db'
  get '/join_dbs/:id/confirm' => 'join_dbs#confirm_password_view', as: 'confirm_join_db_password'
  post '/confirm_join_db_password' => 'join_dbs#confirm_password'
  get '/join_dbs/:id/connections' => 'join_dbs#show_connections', as: 'join_db_connections'
  get '/join_dbs/:id/mappings' => 'join_dbs#show_mappings', as: 'join_db_mappings'

  #RemoteDb routes
  get 'remote_dbs/new' => 'remote_dbs#new'
  get '/remote_dbs/:id' => 'remote_dbs#show', as: 'remote_db'
  post '/remote_dbs' => 'remote_dbs#create'
  get '/remote_dbs/:id/edit' => 'remote_dbs#edit', as: 'edit_remote_db'
  patch '/remote_dbs/:id' => 'remote_dbs#update'
  get '/remote_dbs/:id/delete' => 'remote_dbs#destroy', as: 'delete_remote_db'
  post '/refresh_remote_db/:id' => 'remote_dbs#refresh', as: 'refresh_remote_db'
  get 'remote_dbs/:id/show_table/:table_name' => 'remote_dbs#show_table', as: 'show_table'
  get 'remote_dbs/:id/download_table/:table_name' => 'remote_dbs#download_table', as: 'download_table', defaults: {format: :csv}

  # Mapping routes
  get 'mappings/new' => 'mappings#new'
  post '/mappings' => 'mappings#create'
  get 'mappings/:id/download' => 'mappings#download_table', as: 'download_mapping', defaults: {format: :csv}

  # Webhook routes for Chargebee events
  post '/subscription_events' => 'webhooks#subscription_events'
end
