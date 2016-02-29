Rails.application.routes.draw do

  root to: 'home#index'
  resources :competitions, only: [:index, :show] do
    collection do
      get :apply_event
      post :update_apply_info
    end
  end

  devise_for :users, path: 'account', controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations',
                       passwords: 'users/passwords',
                       confirmations: 'users/confirmations'}
  mount RuCaptcha::Engine => '/rucaptcha'


  # -----------------------------------------------------------
  # User
  # -----------------------------------------------------------

  get 'user' => redirect('/user/preview')

  match 'user/preview' => 'user#preview', as: 'user_preview', via: [:get, :post]
  match 'user/email' => 'user#email', as: 'user_email', via: [:get, :post]
  match 'user/profile' => 'user#profile', as: 'user_profile', via: [:get, :post]
  match 'user/update_avatar' => 'user#update_avatar', as: 'user_update_avatar', via: [:post]
  match 'user/remove_avatar' => 'user#remove_avatar', as: 'user_remove_avatar', via: [:post]
  match 'user/passwd' => 'user#passwd', as: 'user_passwd', via: [:get, :post]
  match 'user/mobile' => 'user#mobile', as: 'user_mobile', via: [:get, :post]
  match 'user/send_email_code' => 'user#send_email_code', as: 'user_send_email_code', via: [:post]
  match 'user/send_add_mobile_code' => 'user#send_add_mobile_code', as: 'user_send_add_mobile_code', via: [:post]

  # -----------------------------------------------------------
  # Admin
  # -----------------------------------------------------------

  get '/admin/' => 'admin#index'

  namespace :admin do |admin|

    resources :accounts, only: [:new, :index, :create, :destroy] do
      collection do
        get :change_password
        post :change_password_post
      end
    end

    resources :admins
    resources :users
    resources :organizers
    resources :schedules
    resources :roles
    resources :districts

    resources :competitions do
      collection do
        get :get_events
      end
    end
    resources :events do
      collection do
        get :teams
        get :scores
        get :add_score
        post :add_score
        get :edit_score
        post :edit_score
        post :create_team
        post :add_team_player
        post :delete_team_player
        post :delete_team
      end
    end

  end


  match '*path', via: :all, to: 'home#error_404'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
