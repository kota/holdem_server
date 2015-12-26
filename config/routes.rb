Rails.application.routes.draw do
  resource  :session

  resources :games do
    resources :hands, module: 'games' do
      resources :hand_actions
    end
    resources :players, module: 'games'
  end

  root 'games#index'
end
