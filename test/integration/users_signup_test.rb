require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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

  test 'valid signup' do
    get signup_path
    assert_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "User",
          email: "user@example.com",
          password: "foobar",
          password_confirmation: "foobar"
        }
      }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
