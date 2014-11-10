require 'sidekiq/web'
XiaomaTofelAdmin::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: "vocabulary_questions#index"
  mount Sidekiq::Web => '/sidekiq'
  resources :vocabulary_questions do
    get :index_upload, on: :collection
    post :upload_vocabulary, on: :collection
  end

  resources :grammar_groups

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
    end
  end

  resources :reproduction_questions

  resources :jijing_questions

  resources :jijing_groups

  resources :jijing_tasks
end
