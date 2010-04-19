ActionController::Routing::Routes.draw do |map|
  map.root :controller => "contact"

  map.connect ':controller/:action/:id'
end
