require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @user2 = users(:ahmad)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_match flash[:danger], "You must be logged in to do that!"
    assert_redirected_to login_path
  end

  test 'should redirect update when not logged in' do
    name = "Georgie"
    email = "georgie@whitie.com"
    patch user_path(@user), params: {
      name: name,
      email: email
    }
    assert_not flash.empty?
    assert_match flash[:danger], "You must be logged in to do that!"
    assert_redirected_to login_path
  end

  test 'user can only edit his/her own profile' do
    log_in_as(@user2)
    assert_redirected_to user_path(@user2)
    get edit_user_path(@user)
    assert_redirected_to root_path
  end

  test 'user can only update his/her own profile' do
    log_in_as(@user2)
    name = "Tonying"
    email = "im_bad@gmail.com"
    patch user_path(@user), params: {
      name: name,
      email: email
    }
    assert_not flash.empty?
    assert_match flash[:danger], "Don't do that to someone else's profile dude!
    "
    assert_redirected_to root_path
  end

end
