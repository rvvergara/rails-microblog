require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user1 = users(:michael)
    @user2 = users(:ahmad)
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get users_path
    assert_select "a[href=?]", users_path, count: 0
    log_in_as(@user1)
    follow_redirect!
    assert_select "a[href=?]", users_path
    get edit_user_path(@user2)
    assert_not flash.empty?
    assert_match flash[:danger], "Don't do that to someone else's profile dude!"
  end
end
