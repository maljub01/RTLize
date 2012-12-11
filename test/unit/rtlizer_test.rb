require 'test_helper'

class RtlizerTest < ActiveSupport::TestCase
  def assert_declaration_transformation(from, to, one_way = false)
    assert_equal(to, Rtlize::RTLizer.transform_declarations(from))
    assert_equal(from, Rtlize::RTLizer.transform_declarations(to)) unless one_way
  end

  def assert_no_declaration_transformation(css)
    assert_equal(css, Rtlize::RTLizer.transform_declarations(css))
  end

  def assert_transformation(from, to, one_way = false)
    assert_equal(to, Rtlize::RTLizer.transform(from))
    assert_equal(from, Rtlize::RTLizer.transform(to)) unless one_way
  end

  def assert_no_transformation(css)
    assert_equal(css, Rtlize::RTLizer.transform(css))
  end

  test "Should transform the border properties properly" do
    assert_declaration_transformation("border-left: 1px solid red;", "border-right: 1px solid red;")

    assert_declaration_transformation("border-left-color: red;",   "border-right-color: red;")
    assert_declaration_transformation("border-left-style: solid;", "border-right-style: solid;")
    assert_declaration_transformation("border-left-width: 1px;",   "border-right-width: 1px;")

    assert_declaration_transformation("border-color: #111 #222 #333 #444;",        "border-color: #111 #444 #333 #222;")
    assert_declaration_transformation("border-style: dotted solid double dashed;", "border-style: dotted dashed double solid;")
    assert_declaration_transformation("border-width: 1px 2px 3px 4px;",            "border-width: 1px 4px 3px 2px;")
  end

  test "Should transform the border-radius property" do
    ["border-radius", "-moz-border-radius", "-webkit-border-radius"].each do |prop|
      assert_declaration_transformation(   "#{prop}: 1px 2px 3px 4px;", "#{prop}: 2px 1px 4px 3px;")
      assert_declaration_transformation(   "#{prop}: 1px 2px 3px;",     "#{prop}: 2px 1px 2px 3px;", true)
      assert_declaration_transformation(   "#{prop}: 1px 2px;",         "#{prop}: 2px 1px;")
      assert_no_declaration_transformation("#{prop}: 1px;")
    end

    ['top', 'bottom'].each do |side|
      assert_declaration_transformation("border-#{side}-left-radius:         1px;", "border-#{side}-right-radius:         1px;")
      assert_declaration_transformation("-moz-border-radius-#{side}left:     1px;", "-moz-border-radius-#{side}right:     1px;")
      assert_declaration_transformation("-webkit-border-#{side}-left-radius: 1px;", "-webkit-border-#{side}-right-radius: 1px;")
    end
  end

  test "Should transform the clear/float properties" do
    assert_declaration_transformation("clear: left;", "clear: right;")
    assert_declaration_transformation("float: left;", "float: right;")
  end

  test "Should transform the direction property" do
    assert_declaration_transformation("direction: ltr;", "direction: rtl;")
  end

  test "Should transform the left/right position properties" do
    assert_declaration_transformation("left: 1px;", "right: 1px;")
  end

  test "Should transform the margin property" do
    assert_declaration_transformation("margin: 1px 2px 3px 4px;", "margin: 1px 4px 3px 2px;")
    assert_declaration_transformation("margin-left: 1px;", "margin-right: 1px;")
  end

  test "Should transform the padding property" do
    assert_declaration_transformation("padding: 1px 2px 3px 4px;", "padding: 1px 4px 3px 2px;")
    assert_declaration_transformation("padding-left: 1px;", "padding-right: 1px;")
  end

  test "Should transform the text-align property" do
    assert_declaration_transformation("text-align: left;", "text-align: right;")
  end

  test "Should not transform CSS rules whose selector includes .rtl" do
    assert_no_transformation(".klass span.rtl #id { float: left; }")
  end

  test "Should not transform CSS marked with no-rtl" do
    assert_no_transformation(<<-CSS)
      /*!= begin(no-rtl) */

      .klass { float: left; }

      /*!= end(no-rtl) */
    CSS
  end
end
