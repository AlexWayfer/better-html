require 'test_helper'
require 'ostruct'
require 'better_html/better_erb'

class BetterHtml::BetterErb::ImplementationTest < ActiveSupport::TestCase
  test "simple template rendering" do
    assert_equal "<foo>some value<foo>",
      render("<foo><%= bar %><foo>", { bar: 'some value' })
  end

  test "html_safe interpolation" do
    assert_equal "<foo><bar /><foo>",
      render("<foo><%= bar %><foo>", { bar: '<bar />'.html_safe })
  end

  test "non html_safe interpolation" do
    assert_equal "<foo>&lt;bar /&gt;<foo>",
      render("<foo><%= bar %><foo>", { bar: '<bar />' })
  end

  test "interpolate non-html_safe inside attribute is escaped" do
    assert_equal "<a href=\" &#39;&quot;&gt;x \">",
      render("<a href=\"<%= value %>\">", { value: ' \'">x ' })
  end

  test "interpolate html_safe inside attribute is magically force-escaped" do
    assert_equal "<a href=\" &#39;&quot;&gt;x \">",
      render("<a href=\"<%= value %>\">", { value: ' \'">x '.html_safe })
  end

  test "interpolate html_safe inside single quoted attribute" do
    assert_equal "<a href=\' &#39;&quot;&gt;x \'>",
      render("<a href=\'<%= value %>\'>", { value: ' \'">x '.html_safe })
  end

  test "interpolate in attribute without quotes" do
    e = assert_raises(BetterHtml::DontInterpolateHere) do
      render("<a href=<%= value %>>", { value: "" })
    end
    assert_equal "Do not interpolate without quotes around this "\
      "attribute value. Instead of <a href=<%= your code %>> "\
      "try <a href=\"<%= your code %>\">.", e.message
  end

  test "interpolate in attribute after value" do
    e = assert_raises(BetterHtml::DontInterpolateHere) do
      render("<a href=something<%= value %>>", { value: "" })
    end
    assert_equal "Do not interpolate without quotes around this "\
      "attribute value. Instead of <a href=something<%= your code %>> "\
      "try <a href=\"something<%= your code %>\">.", e.message
  end

  test "interpolate in tag name" do
    assert_equal "<tag-safe-foo>",
      render("<tag-<%= value %>-foo>", { value: "safe" })
  end

  test "interpolate in tag name with space" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<tag-<%= value %>-foo>", { value: "un safe" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a tag name around: <tag-<%= your code %>.", e.message
  end

  test "interpolate in tag name with slash" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<tag-<%= value %>-foo>", { value: "un/safe" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a tag name around: <tag-<%= your code %>.", e.message
  end

  test "interpolate in tag name with end of tag" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<tag-<%= value %>-foo>", { value: "><script>" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a tag name around: <tag-<%= your code %>.", e.message
  end

  test "interpolate in comment" do
    assert_equal "<!-- safe -->",
      render("<!-- <%= value %> -->", { value: "safe" })
  end

  test "interpolate in comment with end-of-comment" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<!-- <%= value %> -->", { value: "-->" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a html comment around: <!-- <%= your code %>.", e.message
  end

  test "interpolate in script tag" do
    assert_equal "<script> foo safe bar<script>",
      render("<script> foo <%= value %> bar<script>", { value: "safe" })
  end

  test "interpolate in script tag with start of comment" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<script> foo <%= value %> bar<script>", { value: "<!--" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a script tag around: <script> foo <%= your code %>.", e.message
  end

  test "interpolate in script tag with start of script" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<script> foo <%= value %> bar<script>", { value: "<script" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a script tag around: <script> foo <%= your code %>.", e.message
  end


  test "interpolate in script tag with start of script case insensitive" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<script> foo <%= value %> bar<script>", { value: "<ScRIpT" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a script tag around: <script> foo <%= your code %>.", e.message
  end

  test "interpolate in script tag with end of script" do
    e = assert_raises(BetterHtml::UnsafeHtmlError) do
      render("<script> foo <%= value %> bar<script>", { value: "</script" })
    end
    assert_equal "Detected invalid characters as part of the interpolation "\
      "into a script tag around: <script> foo <%= your code %>.", e.message
  end

  private

  def render(source, locals)
    src = BetterHtml::BetterErb::Implementation.new(source).src
    context = OpenStruct.new(locals)
    context.instance_eval(src)
  end
end
