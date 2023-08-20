class ActionDispatch::Routing::Mapper
  def breath(routes_name, &resources)
    namespace routes_name do
      get "/" => "sessions#new"
      post "login" => "sessions#login"
      delete "logout" => "sessions#logout"

      resources.call
    end
  end
end
