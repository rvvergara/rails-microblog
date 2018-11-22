require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit for logged users' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: "",
        email: "",
        password: 'password',
        password_confirmation: 'password'
      }
    }
    assert_template 'users/edit'

    assert_select 'div.alert.alert-danger' do
      assert_match '3 errors were encountered, which prevented this user from being saved:', response.body
    end
  end

  test 'successful edit for logged users' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "George"
    email = "george@nba.com"
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: ''
      }
    }
    assert_not_empty flash
    assert_match flash[:success], "Your profile is updated!"
    assert_redirected_to user_path(@user)
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    
    assert session[:forwarding_url], edit_user_path(@user)

    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    
    assert_nil session[:forwarding_url]
    
    name = "George"
    email = "george@nba.com"
    
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: '',
        password_confirmation: ''
      }
    }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email 
  end

end
