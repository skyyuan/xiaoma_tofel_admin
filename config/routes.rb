XiaomaTofelAdmin::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  resources :vocabulary_questions do
    get :index_upload, on: :collection
    post :upload_vocabulary, on: :collection
  end

end
