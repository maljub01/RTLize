Dummy::Application.routes.draw do
  root :to => 'welcome#index'
  scope ":locale" do
    get '/', :to => 'welcome#index'
  end
end
