require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'micropost interface' do
    log_in_as(@user)
    get root_path
    assert_select "ul.pagination"
    assert_match @user.microposts.count.to_s, response.body
    assert_select "a[href=?][data-method=?]", micropost_path(@user.microposts.first), "delete"
    assert_select "input[type=?]", "file"
    #Invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_template "static_pages/home"
    assert_select "div#error_explanation"

    #valid submission
    picture = fixture_file_upload("test/fixtures/kitten.jpg")
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: {micropost: {content: "a"* 140}, picture: picture}
    end

    assert_match flash[:success], "Micropost created!"

    assert_redirected_to root_path

    #visit different user (should be no delete links)
    @user2 = users(:lana)
    get user_path(@user2)
    assert_select "h1", text: @user2.name
    assert_select "a[href=?][data-method=?]", micropost_path(@user2.microposts.first), "delete", count: 0
  end
  
end
