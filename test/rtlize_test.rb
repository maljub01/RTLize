require 'test_helper'

class RtlizeTest < ActiveSupport::TestCase
  def setup
    @app = Rails.application
  end

  test "application.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('application.css', :bundle => bundle).body
      assert_equal ".test { left: 1px; }\n", css
    end
  end

  test "application-symlink.rtl.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('application-symlink.rtl.css', :bundle => bundle).body
      assert_equal ".test { right: 1px; }\n", css
    end
  end

  test "sass-importer.rtl.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('sass-importer.rtl.css', :bundle => bundle).body
      assert_equal(".test-1 {\n  right: 10px; }\n\n.test-2 {\n  float: right; }\n", css)
    end
  end
end
