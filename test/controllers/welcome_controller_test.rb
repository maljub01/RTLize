require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "/" do
    get :index
    assert_select 'html[lang=en]'
    assert_select 'html[dir=ltr]'
  end

  test "/en" do
    get :index, :locale => :en
    assert_select 'html[lang=en]'
    assert_select 'html[dir=ltr]'
  end

  test "/ar" do
    get :index, :locale => :ar
    assert_select 'html[lang=ar]'
    assert_select 'html[dir=rtl]'
  end
end
