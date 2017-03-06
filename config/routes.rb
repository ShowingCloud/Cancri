Rails.application.routes.draw do

  root to: 'home#index'
  devise_for :users, skip: [:sessions], path: 'account', controllers: {
      :omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_scope :user do
    get 'account/sign_in', to: redirect('/account/auth/cas'), :as => :new_user_session
    delete "account/sign_out", :to => 'users/sessions#destroy', :as => :destroy_user_session
  end
  mount RuCaptcha::Engine => '/rucaptcha'

  get '/demeanor' => 'demeanor#index'
  get '/demeanor/videos' => 'demeanor#videos'
  get '/demeanor/get_comps_via_year' => 'demeanor#get_comps_via_year'
  get '/demeanor/:id' => 'demeanor#show'
  get 'courses/index'
  get 'courses/apply_show' => 'courses#apply_show'
  post 'courses/apply' => 'courses#apply'
  post 'courses/cancel' => 'courses#cancel_apply'
  get 'news' => 'news#index'
  get 'news/:id' => 'news#show'
  resources :courses
  resources :competitions, only: [:index, :show] do
    collection do
      get :apply_process
      get :apply_event
      post :leader_batch_apply
      post :already_apply
      post :update_user_info
      post :leader_create_team
      get :search_team
      get :search_user
      post :apply_join_team
      post :leader_invite_player
      post :leader_delete_team
      post :leader_delete_player
      post :player_agree_leader_invite
      post :leader_deal_player_apply
      post :leader_submit_team
      post :school_submit_teams
      post :district_submit_teams
      post :school_refuse_teams
      post :district_refuse_teams
    end
  end
  get '/competitions/:id/events', to: 'competitions#events'
  resources :activities do
    collection do
      post :apply_activity
      get :apply_require
    end
  end
  resources :notifications
  get '/downloads', to: 'downloads#index'
  namespace :kindeditor do
    post '/upload' => 'assets#create'
    get '/filemanager' => 'assets#list'
  end
  resources :course_score_attrs
  resources :course_files
  get '/volunteers', to: 'volunteers#index'
  get '/volunteers/recruit', to: 'volunteers#recruit'
  get '/volunteers/recruit/:id', to: 'volunteers#recruit'
  post '/volunteers/apply_volunteer', to: 'volunteers#apply_volunteer'
  get '/volunteers/cancel_apply', to: 'volunteers#cancel_apply'
  post '/volunteers/apply_event_volunteer', to: 'volunteers#apply_event_volunteer'
  get '/test' => 'test#index'

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
    get '/courses/apply_info/:id' => 'courses#apply_info'


    resources :competitions do
      collection do
        get :get_events
        post :add_event_worker
        post :delete_event_worker
      end
    end
    # get '/competitions/events/:id' => 'competitions#events'
    # get '/competitions/workers/:id' => 'competitions#workers'
    get '/checks/teachers' => 'checks#teachers'
    get '/checks/teacher_list' => 'checks#teacher_list'
    get '/checks/hackers' => 'checks#hackers'
    get '/checks/hacker_list' => 'checks#hacker_list'
    # get '/checks/referee_list' => 'checks#referee_list'
    # get '/checks/referees' => 'checks#referees'
    get '/checks/schools' => 'checks#schools'
    get '/checks/school_list' => 'checks#school_list'
    # get '/checks/points' => 'checks#points'
    # get '/checks/point_list' => 'checks#point_list'
    # post '/checks/audit_point' => 'checks#audit_point'
    post '/checks/review_teacher' => 'checks#review_teacher'
    post '/checks/review_hacker' => 'checks#review_hacker'
    # post '/checks/review_referee' => 'checks#review_referee'
    post '/checks/review_school' => 'checks#review_school'
    get '/checks/volunteers', to: 'checks#volunteers'
    get '/checks/volunteer_list', to: 'checks#volunteer_list'
    post '/checks/review_volunteer' => 'checks#review_volunteer'
    #
    resources :competition_schedules do
      collection do
        post :update_cs
      end
    end
    resources :events do
      collection do
        post :update_formula
        get :teams
        post :add_score_attributes
        post :edit_event_sa_desc
        post :delete_score_attribute
        post :update_score_attrs_sort
        post :update_team_player
        post :add_team_player
        post :delete_team_player
        post :delete_team
        post :create_team
        get :scores
        get :school_sort
        get :export_team_info
        post :update_sa_in_rounds
        post :create_last_score
        post :compute_last_score
        post :delete_score
      end
    end
    resources :teams
    resources :event_schedules do
      collection do
        post :update_is_show
      end
    end
    resources :news
    resources :activities do
      collection do
        post :update_user_score
        post :add_child
      end
      member do
        get :users
        get :add_child
      end
    end
    resources :news_types
    resources :volunteers, only: [:index, :show] do
      collection do
        get :edit_regulation
        post :edit_regulation
        get :regulation
        get :events
      end
    end
    resources :event_volunteers do
      collection do
        get '/volunteer_detail/:id', to: 'event_volunteers#volunteer_detail'
        get '/volunteer_list/:id', to: 'event_volunteers#volunteer_list'
        post '/audit_event_v_user', to: 'event_volunteers#audit_event_v_user'
        post :update_e_v_u_info
      end
    end
    resources :positions
    resources :event_vol_positions
    resources :score_attributes
    resources :photos #, only: [:new, :create, :index,:show]
    resources :videos
    resources :consults
    resources :schools
    resources :notifications
    # get '/vouchers/to_image', to: 'vouchers#to_image'
    # get '/vouchers/export_voucher', to: 'vouchers#export_voucher'
    get '/vouchers/export_xls', to: 'vouchers#export_xls'
    resources :vouchers
  end

  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          post :upload_course_opus
          post :delete_course_opus
          post :update_course_opus
        end
      end
      resources :competitions do
        collection do
          get :get_events
          get :get_parent_group
          get :get_obj_by_status
        end
      end
      resources :events do
        collection do
          get :score_attrs
          get :group_schedules
          get :group_teams
          get :get_team_by_identifier
        end
      end
      resources :notifications do
        collection do
          post :update_read
          get :unread_num
          delete :all
          get :comp_notify
        end
      end
      resources :scores do
        collection do
          post :upload_scores
        end
      end
      resources :schools do
        collection do
          get :get_by_district
        end
      end
      resources :districts do
        collection do
          get :get_provinces
          get :get_cities
          get :get_districts
        end
      end
      match '*path', via: :all, to: 'root#not_found'
    end
  end

  require 'sidekiq/web'
  authenticate :user, ->(u) { u.nickname=='001' } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'user' => redirect('/user/preview')

  get '/user/competitions', to: 'user#competitions'
  get '/user/courses', to: 'user#courses'
  get '/user/activities', to: 'user#activities'
  match 'user/preview' => 'user#preview', as: 'user_preview', via: [:get, :post]
  get 'user/preview/:id' => 'user#preview'
  match 'user/profile' => 'user#profile', as: 'user_profile', via: [:get, :post]
  match 'user/family_hacker' => 'user#family_hacker', as: 'user_family_hacker', via: [:get, :post]
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
  match '/user/apply' => 'user#apply', as: 'user_apply', via: [:get]
  match '/user/cancel_apply' => 'user#cancel_apply', as: 'user_cancel_apply', via: [:post, :get]
  get '/user/get_schools' => 'user#get_schools', as: 'user_get_schools'
  get '/user/get_districts' => 'user#get_districts', as: 'user_get_districts'
  get '/user/get_events' => 'user#get_events', as: 'user_get_events'
  get '/user/get_competitions' => 'user#get_competitions', as: 'user_get_competitions'
  match '/user/programs' => 'user#programs', as: 'user_programs', via: [:get]
  match '/user/programs/:id' => 'user#program', via: [:get]
  get '/user/course_opus/:id' => 'user#course_opus', as: 'user_course_opus'
  get '/user/course_stu_opus/:id' => 'user#course_stu_opus', as: 'user_course_stu_opus'
  post 'user/course_score' => 'user#course_score', as: 'user_course_score'
  match 'user/create_program' => 'user#create_program', as: 'user_create_program', via: [:get, :post]
  match 'user/program_se/:id' => 'user#program_se', as: 'user_program_se', via: [:get, :post]
  match 'user/course_ware/:id' => 'user#course_ware', as: 'user_course_ware', via: [:get, :post]
  get 'user/student_manage' => 'user#student_manage', as: 'user_student_manage'
  get 'user/comp_student' => 'user#comp_student', as: 'user_comp_student'
  get 'user/get_comp_students' => 'user#get_comp_students', as: 'user_get_comp_students'
  get 'user/role_apply', to: 'user#role_apply', as: 'user_role_apply'
  post 'user/apply_teacher', to: 'user#apply_teacher', as: 'user_apply_teacher'
  get 'user/hacker_apply', to: 'user#hacker_apply', as: 'user_hacker_apply'
  post 'user/hacker_apply_post', to: 'user#hacker_apply_post', as: 'user_hacker_apply_post'
  match 'user/teacher_audit', to: 'user#teacher_audit', as: 'user_teacher_audit', via: [:get, :post]
  get 'user/teachers', to: 'user#teachers', as: 'user_teachers'
  match 'user/hacker_audit', to: 'user#hacker_audit', as: 'user_hacker_audit', via: [:get, :post]
  get 'user/hacker_info/:id', to: 'user#hacker_info', as: 'user_hacker_info'
  # get 'user/join_voucher', to: 'user#join_voucher'
  get 'user/export_voucher', to: 'user#export_voucher'
  mount ActionCable.server => '/cable'
  match '*path', via: :all, to: 'home#error_404'

  # get '/auth/:provider/callback', to: 'sessions#create'
end
