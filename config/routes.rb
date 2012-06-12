ActionController::Routing::Routes.draw do |map|
  map.connect "/roadmaps", :controller => "roadmaps_main", :action => "index", :conditions => { :method => :get}
end
