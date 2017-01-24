require 'test_helper'

class RtlizeTest < ActiveSupport::TestCase
  def setup
    @app = Rails.application
  end

  test "application.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('application.css', :bundle => bundle)
      assert_equal ".test{left:1px;right:10px}\n", css.to_s
    end
  end

  test "application-symlink.rtl.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('application-symlink.rtl.css', :bundle => bundle)
      assert_equal ".test{right:1px;left:10px}\n", css.to_s
    end
  end

  test "sass-importer.rtl.css" do
    [false, true].each do |bundle|
      css = @app.assets.find_asset('sass-importer.rtl.css', :bundle => bundle)
      assert_equal(".test-1{right:10px}.test-2{float:right}\n", css.to_s)
    end
  end


end
