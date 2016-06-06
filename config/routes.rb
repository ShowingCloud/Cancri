Rails.application.routes.draw do

  root to: 'home#index'
  devise_for :users, path: 'account', controllers: {
      sessions: 'users/sessions', registrations: 'users/registrations',
      confirmations: 'users/confirmations',
      passwords: 'users/passwords'
  }
  mount RuCaptcha::Engine => '/rucaptcha'
  resources :accounts, only: [:new, :create, :destroy] do
    collection do
      get :register
      post :register_post
      post :validate_captcha
      get :forget_password
      get :reset_password
      post :reset_password_post
      post :send_code
      post :register_email_exists
      post :register_mobile_exists
      post :register_nickname_exists
    end
  end

  resources :notifications

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
    resources :courses


    resources :competitions do
      collection do
        get :get_events
        post :add_event_worker
        post :delete_event_worker
      end
    end
    # get '/competitions/events/:id' => 'competitions#events'
    # get '/competitions/workers/:id' => 'competitions#workers'
    # get '/checks/teachers' => 'checks#teachers'
    # get '/checks/teacher_list' => 'checks#teacher_list'
    # get '/checks/referee_list' => 'checks#referee_list'
    # get '/checks/referees' => 'checks#referees'
    # get '/checks/schools' => 'checks#schools'
    # get '/checks/school_list' => 'checks#school_list'
    # get '/checks/points' => 'checks#points'
    # get '/checks/point_list' => 'checks#point_list'
    # post '/checks/audit_point' => 'checks#audit_point'
    # post '/checks/review_teacher' => 'checks#review_teacher'
    # post '/checks/review_referee' => 'checks#review_referee'
    # post '/checks/review_school' => 'checks#review_school'
    #
    resources :competition_schedules do
      collection do
        post :update_cs
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
        post :add_score_attributes
        post :delete_score_attribute
        post :edit_event_sa_desc
      end
    end
    resources :event_schedules
    resources :news
    resources :activities
    resources :news_types
    resources :volunteers
    resources :score_attributes
    resources :photos
    resources :videos
    resources :consults
  end

  get 'user' => redirect('/user/preview')

  match 'user/preview' => 'user#preview', as: 'user_preview', via: [:get, :post]
  match 'user/profile' => 'user#profile', as: 'user_profile', via: [:get, :post]
  match 'user/update_avatar' => 'user#update_avatar', as: 'user_update_avatar', via: [:post]
  match 'user/remove_avatar' => 'user#remove_avatar', as: 'user_remove_avatar', via: [:post]
  match 'user/passwd' => 'user#passwd', as: 'user_passwd', via: [:get, :post]
  match 'user/mobile' => 'user#mobile', as: 'user_mobile', via: [:get, :post]
  match 'user/email' => 'user#email', as: 'user_email', via: [:get, :post]
  match 'user/reset_mobile' => 'user#reset_mobile', as: 'user_reset_mobile', via: [:get, :post]
  match 'user/reset_email' => 'user#reset_email', as: 'user_reset_email', via: [:get, :post]
  match 'user/send_email_code' => 'user#send_email_code', as: 'user_send_email_code', via: [:post]
  match 'user/send_add_mobile_code' => 'user#send_add_mobile_code', as: 'user_send_add_mobile_code', via: [:post]
  match 'user/comp' => 'user#comp', as: 'user_comp', via: [:get]
  match 'user/consult' => 'user#consult', as: 'user_consult', via: [:get, :post]
  match 'user/point' => 'user#point', as: 'user_point', via: [:get, :post]
  match 'user/add_point' => 'user#add_point', as: 'user_add_point', via: [:get, :post]
  match 'user/notification' => 'user#notification', as: 'user_notification', via: [:get]
  get '/user/notify' => 'user#notify_show'
  match '/user/add_school' => 'user#add_school', as: 'user_add_school', via: [:post]
  # mount ActionCable.server => '/cable'
end
