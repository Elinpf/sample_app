# 参考https://stackoverflow.com/questions/22288951/actionviewtemplateerror-missing-host-to-link-to-please-provide-the-host-p
# NOTE 由于和教材中的不一样,做了在这里加入了host地址 
# 这里其实是所有环境都加了,其实是不用的,在test中有修改
#Rails.application.routes.default_url_options[:host] = 'localhost:3000'

Rails.application.routes.draw do

  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

	root 'static_pages#home'
  get '/help', to: 'static_pages#help'
	get '/about', to: 'static_pages#about'
	get '/contact', to: 'static_pages#contact'

	get '/signup', to: 'users#new'
	get '/login', to: 'sessions#new'
	post '/login', to: 'sessions#create'
	delete 'logout', to: 'sessions#destroy'

	resources :users

	# 创建只有edit_account_activation 的路由
	resources :account_activations, only: [:edit]
	
	resources :password_resets, only: [:new, :create, :edit, :update]
end
