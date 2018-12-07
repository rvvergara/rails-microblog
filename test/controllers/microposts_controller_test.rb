require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @micropost = microposts(:orange)
  end

  test 'should redirect create when user not logged in' do
    assert_no_difference "Micropost.count" do
      post microposts_path, params: {
        content: Faker::Lorem.sentence(5)
      }
    end
    assert_redirected_to login_path
  end

  test 'should redirect destroy when user not logged in' do
    assert_no_difference "Micropost.count" do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_path
  end

  test 'should redirect destroy for wrong micropost' do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference "Micropost.count" do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end

end
