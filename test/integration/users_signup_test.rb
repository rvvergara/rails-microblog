require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
  get signup_path
  assert_no_difference 'User.count' do
      assert_select 'form[action="/signup"]'
      post users_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end
  end

  test 'valid signup information with activation' do
    get signup_path
    assert_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "Example User",
          email: "user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    assert_redirected_to root_path
    # Valid activation path
    get edit_account_activation_path(user.activation_token, email:user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_match flash[:success], "Your account is activated! Welcome to Microblog #{user.name}!"
    assert is_logged_in?
  end
end
