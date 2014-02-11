require 'test_helper'

class RtlizeTest < ActiveSupport::TestCase
  def setup
    @app = Dummy::Application
  end

  test "application.css" do
    css = Dummy::Application.assets.find_asset('application.css').body
    assert_equal ".test { left: 1px; }\n", css
  end

  test "application.rtl.css" do
    css = Dummy::Application.assets.find_asset('application.rtl.css').body
    assert_equal ".test { right: 1px; }\n", css
  end
end
