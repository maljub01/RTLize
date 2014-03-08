require 'test_helper'

class HelpersTest < ActiveSupport::TestCase
  test ".dir" do
    I18n.locale = :en
    assert_equal("ltr", Rtlize.dir)
    assert_equal("rtl", Rtlize.dir(:ar))

    I18n.locale = :ar
    assert_equal("rtl", Rtlize.dir)
    assert_equal("ltr", Rtlize.dir('en'))
  end
end
