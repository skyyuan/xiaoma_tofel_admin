require 'sidekiq/web'
XiaomaTofelAdmin::Application.routes.draw do

  devise_for :admins
  root to: "vocabulary_questions#index"
  mount Sidekiq::Web => '/sidekiq'
  resources :vocabulary_questions do
    get :index_upload, on: :collection
    post :upload_vocabulary, on: :collection
    post :delete, on: :collection
    get :unit, on: :collection
  end

  resources :grammar_groups

  resources :live_broadcasts

  resources :admins do
    post :create_admin, on: :collection
    post :update_admin, on: :collection
  end

  resources :beck_questions do
    post :delete, on: :collection
  end

  resources :grammar_questions do
    get :select_unit, on: :collection
    get :edit_title, on: :collection
  end

  resources :jinghua_questions

  resources :dictation_questions do
    collection do
      get :choose_unit
      # get :add_dictation_group
      # post :create_dictation_group
    end
  end

  resources :oral_questions do
    collection do
      get :choose_range
      get :unit_list
      get :next_unit
    end
  end

  resources :reproduction_questions

  resources :jijing_questions

  resources :jijing_groups

  resources :jijing_tasks

  resources :jijing_works do
    get :new_group, on: :collection
    get :new_type, on: :collection
  end

  resources :tpo_questions do
    get :writ_index, on: :collection
    get :writ_new_type, on: :collection
    post :writ_new_type_create, on: :collection
    get :writ_new, on: :collection
  end

  resources :tpo_spokens do
    get :new_type, on: :collection
    post :new_type_create, on: :collection
  end

  resources :tpo_reads do
    collection do
      get :choose_range
      get :change_question_type
      get :upload_file
      post :batch_import
      get :add_tpo
      post :create_tpo
    end
  end

  resources :tpo_listens do
    collection do
      get :choose_range
      get :change_question_type
      get :upload_file
      post :batch_import
      get :add_tpo
      post :create_tpo
    end
  end
end
