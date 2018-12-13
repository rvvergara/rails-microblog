require 'test_helper'

class HomePageTest < ActionDispatch::IntegrationTest
  
  def setup
    @michael = users(:michael)
    @archer = users(:archer)
  end

  test 'stats show on homepage' do
    log_in_as(@michael)
    
    get user_path(@archer)
    # @archer.follow(@michael)
    assert_select "a[href=?]", following_user_path(@archer)
    assert_match @archer.following.count.to_s, response.body 
    
    get user_path(@michael)
    assert_match @michael.followers.count.to_s, response.body
  end

end
