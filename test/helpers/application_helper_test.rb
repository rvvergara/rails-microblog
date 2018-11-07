require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, "Rails Microblog"
    assert_equal full_title("Help"), "Help | Rails Microblog"
    assert_equal full_title("Signup"), "Signup | Rails Microblog"
  end
end