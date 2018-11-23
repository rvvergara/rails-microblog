require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @user2 = users(:ahmad)
    @other_user = users(:archer)
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
      user: {name: name,
      email: email}
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
      user: {name: name,
      email: email}
    }
    assert_not flash.empty?
    assert_match flash[:danger], "Don't do that to someone else's profile dude!
    "
    assert_redirected_to root_path
  end

  test 'only logged in users can see users list' do
    get users_path
    assert_redirected_to login_path
  end


test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { 
                                        password:              '',
                                            password_confirmation: '',
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end

end
