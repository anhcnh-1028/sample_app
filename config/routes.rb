Rails.application.routes.draw do
  root "static_pages#home"

  get "static_pages/help"
  get "static_pages/about"
  scope "(:locale)", locale: /en|vi/ do
    resources :microposts
    resources :users
  end
end
