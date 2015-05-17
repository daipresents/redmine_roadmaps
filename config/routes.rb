Rails.application.routes.draw do 
  resources :projects do
    resources :roadmaps_main, :only => :index
  end
end
