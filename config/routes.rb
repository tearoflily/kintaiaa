Rails.application.routes.draw do
  get 'sessions/new'

  root 'static_pages#top'
  

  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'



  
  resources :users do
    collection { post :import }
    member do
      
    end
    get 'attendances/edit'
    resources :attendances do
      collection { patch :edit_confirmation
                   post :update_waiting
                   get :edit_confirm
                   get :log
                  patch :update
      }
      member do
        
        
      end
    end
  end
  

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
