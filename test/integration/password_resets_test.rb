require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'invalid and valid password reset' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, params: {
      password_reset: {
        email: "joke@user.com"
      }
    }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # valid email
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    assert_match flash[:info], "Email sent with password reset instructions."
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_path
    # Invalid email
    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_path
    assert_match flash[:danger], "Wrong link"
 
    #Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_path
    user.toggle!(:activated)

    # Right email but wrong token
    get edit_password_reset_path(user.reset_token + "frarjara", email: user.email)
    assert_redirected_to root_path

    # Right email and token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[type="hidden"][value="patch"]'
    assert_select 'input[name="email"][value=?]', user.email

    # Invalid password and confirmation
    patch password_reset_path, params: {
      email: user.email,
      user: {
        password: "",
        password_confirmation: ""
      }
    }
    assert_select "div#error_explanation"
    assert_template 'password_resets/edit'
    #Valid password and confirmation
    patch password_reset_path, params: {
      email: user.email,
      user: {
        password: "password",
        password_confirmation: "password"
      }
    }
    assert_nil user.reload.reset_digest
    assert_redirected_to user_path(user)
    assert_match flash[:success], "Password changed"
  end

  test 'expired token' do
    # Expired reset link
    get new_password_reset_path
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(@user.reset_token, email: @user.email)
    assert_match flash[:danger], "Password reset has expired"
    assert_redirected_to new_password_reset_path
    patch password_reset_path, params: {
      email: @user.email,
      user: {
        password: "password",
        password_confirmation: "password"
      }
    }
    assert_match flash[:danger], "Password reset has expired"
    assert_redirected_to new_password_reset_path
  end
end
