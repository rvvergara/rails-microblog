require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test 'first page of users is viewable by a logged in user' do
    get login_path
    log_in_as(@admin)
    assert_redirected_to user_path(@admin)
    assert 'a[href=?]', users_path 
    get users_path
    assert_template 'users/index'
    assert_select 'ul.pagination', count: 2
    User.paginate(page:1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'ul.pagination'
    first_page_of_users = User.paginate(page: 1)
    assert_select 'a[href=?]', user_path(@admin), text: 'delete', count: 0
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'Delete'
      end
    end
  end

  test 'delete buttons do not appear for non-admins' do
    log_in_as(@non_admin)
    assert_not @non_admin.admin?
    get users_path
    User.paginate(page:1).each do |user|
      assert_select 'a[data-method=?]', user_path(user), method: "delete", count: 0
    end
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@non_admin)
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_redirected_to root_url
  end

  test 'admin should be able to delete user' do
    log_in_as(@admin)
    assert @admin.admin?
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_redirected_to users_path
  end

end
