ActionController::Routing::Routes.draw do |map|
  map.root :controller => "main"

  map.connect ':controller/:action/:id'
end
