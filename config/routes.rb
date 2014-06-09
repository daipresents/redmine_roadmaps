Rails.application.routes.draw do 
  resources :projects do
    resources :roadmaps_main
  end
  resources :projects, :path => 'projects/:action', :only => [:index, :show]
end
