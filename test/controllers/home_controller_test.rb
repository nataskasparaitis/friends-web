require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index while signed out" do
    get home_index_url
    assert_response :success
  end

  test "should get about while signed out" do
    get home_about_url
    assert_response :success
  end

  test "root path is the friends list" do
    get root_url
    assert_redirected_to new_user_session_url

    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
