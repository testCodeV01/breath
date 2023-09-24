class ActionDispatch::Routing::Mapper
  def breath(routes_name, &resources)
    namespace routes_name do
      get "/login" => "sessions#new"
      post "login" => "sessions#login"
      delete "logout" => "sessions#logout"

      resources.call if resources.present?
    end
  end
end
