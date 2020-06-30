Rails.application.routes.draw do
  get 'sessions/new'

  root 'static_pages#top'
  

  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :bases
  
  get '/working_now', to: 'attendances#working_now'
  
  resources :users do
    collection { post :import }
    member do
      
    end
    get 'attendances/edit'
 
    resources :attendances do
      collection { patch :edit_confirmation
                   post :update_waiting
                   get :edit_confirm
                   get :attendance_log
                   
                   post :overwork_confirm_update
                   get :overwork_confirm
                   patch :update
                   get :month_confirmation
                   patch :month_confirmation_update
                   post :month_confirmation_create
      }
      member do
        get :overwork
        post :overwork_update
      end
    end
  end
  

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
