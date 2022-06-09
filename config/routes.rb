Rails.application.routes.draw do
  root "concerts#index"

  resources :concerts, only: [:index] do
    resources :bookings, only: [:new, :create]
  end
end
