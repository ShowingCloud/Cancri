Rails.application.routes.draw do

  root to: 'home#index'
  resources :competitions, only: [:index, :show] do
    collection do
      get :apply_event
      get :invite
      get :search_team
      get :search_user
      post :invite
      post :update_apply_info
      post :leader_create_team
      post :leader_invite_player
      post :apply_join_team
      post :leader_agree_apply
      post :delete_team
      post :leader_delete_player
      post :player_cancel_join
      post :leader_deal_cancel_team
      post :already_apply
    end
  end
  resource :chats
  resources :news
  get '/honors' => 'honors#index'
  get '/demeanor' => 'demeanor#index'
  get '/activities/apply_activity' => 'activities#apply_activity'
  resources :activities do
    collection do
      post :apply_activity
      get :apply_require
    end
  end
  resources :volunteers do
    collection do
      post :apply_comp_volunteer
      get :apply_require
    end
  end
  get '/downloads' => 'downloads#index'
  get '/scenes' => 'scenes#index'
  resource :notifications


  devise_for :users, path: 'account', controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations',
                       passwords: 'users/passwords',
                       confirmations: 'users/confirmations'}
  mount RuCaptcha::Engine => '/rucaptcha'

  # ios Provider
  match '/auth/login/authorize' => 'auth#authorize', via: :all
  match '/auth/login/access_token' => 'auth#access_token', via: :all
  match '/auth/login/user' => 'auth#user', via: :all
  match '/oauth/token' => 'auth#access_token', via: :all

  resources :accounts, only: [:new, :create, :destroy] do
    collection do
      post :validate_captcha
      get :reset_password
      post :send_code
      post :reset_password_post
    end
  end
  resources :test

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
        post :add_event_worker
        post :delete_event_worker
      end
    end
    get '/competitions/events/:id' => 'competitions#events'
    get '/competitions/workers/:id' => 'competitions#workers'
    get '/checks/teachers' => 'checks#teachers'
    get '/checks/teacher_list' => 'checks#teacher_list'
    get '/checks/referee_list' => 'checks#referee_list'
    get '/checks/referees' => 'checks#referees'
    get '/checks/points' => 'checks#points'
    get '/checks/point_list' => 'checks#point_list'
    post '/checks/audit_point' => 'checks#audit_point'
    post '/checks/review_teacher' => 'checks#review_teacher'
    post '/checks/review_referee' => 'checks#review_referee'

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
    resources :news
    resources :activities
    resources :news_types
    resources :volunteers
    resources :score_attributes
    resources :photos
    resources :videos
    resources :consults
  end
  namespace :kindeditor do
    post '/upload' => 'assets#create'
    get '/filemanager' => 'assets#list'
  end


  mount Soulmate::Server, :at => '/sm'

  # use_doorkeeper do
  #   controllers applications: 'oauth/applications', authorized_applications: 'oauth/authorized_applications'
  # end

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
  match 'user/reset_mobile' => 'user#reset_mobile', as: 'user_reset_mobile', via: [:get, :post]
  match 'user/reset_email' => 'user#reset_email', as: 'user_reset_email', via: [:get, :post]
  match 'user/mobile' => 'user#mobile', as: 'user_mobile', via: [:get, :post]
  match 'user/send_email_code' => 'user#send_email_code', as: 'user_send_email_code', via: [:post]
  match 'user/send_add_mobile_code' => 'user#send_add_mobile_code', as: 'user_send_add_mobile_code', via: [:post]
  match 'user/comp' => 'user#comp', as: 'user_comp', via: [:get]
  match 'user/consult' => 'user#consult', as: 'user_consult', via: [:get, :post]
  match 'user/point' => 'user#point', as: 'user_point', via: [:get, :post]
  match 'user/add_point' => 'user#add_point', as: 'user_add_point', via: [:get, :post]
  match 'user/notification' => 'user#notification', as: 'user_notification', via: [:get]
  get '/user/notify' => 'user#notify_show'
  match '/user/agree_invite_info' => 'user#agree_invite_info', via: [:post]
  match '/user/add_school' => 'user#add_school', as: 'user_add_school', via: [:post]
  match '/user/check_email_exists' => 'user#check_email_exists', as: 'user_check_email_exists', via: [:post]
  match '/user/check_mobile_exists' => 'user#check_mobile_exists', as: 'user_check_mobile_exists', via: [:post]
  match '/user/check_email_mobile' => 'user#check_email_mobile', as: 'user_check_email_mobile', via: [:post]

  mount API::Dispatch => '/'


  match '*path', via: :all, to: 'home#error_404'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
