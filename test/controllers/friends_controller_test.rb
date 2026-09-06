require "test_helper"

class FriendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user           = users(:one)
    @friend         = friends(:one)   # belongs to @user
    @others_friend  = friends(:two)   # belongs to users(:two)
    sign_in @user
  end

  # --- signed out ---------------------------------------------------------

  test "redirects to sign in when signed out" do
    sign_out @user

    get friends_url
    assert_redirected_to new_user_session_url

    get new_friend_url
    assert_redirected_to new_user_session_url

    get friend_url(@friend)
    assert_redirected_to new_user_session_url
  end

  # --- index --------------------------------------------------------------

  test "should get index" do
    get friends_url
    assert_response :success
  end

  test "index lists only the signed-in user's friends" do
    get friends_url
    assert_select "tbody#friends tr", 1
    assert_match @friend.first_name, response.body
    assert_no_match(/#{@others_friend.first_name}/, response.body)
  end

  test "index filters by the search query" do
    @user.friends.create!(first_name: "Alan", last_name: "Turing", email: "alan@example.com")

    get friends_url(q: "Turing")
    assert_response :success
    assert_match "Turing", response.body
    assert_no_match(/Lovelace/, response.body)
  end

  test "a blank search query lists everything" do
    get friends_url(q: "")
    assert_response :success
    assert_match @friend.last_name, response.body
  end

  # --- show / new / edit --------------------------------------------------

  test "should get new" do
    get new_friend_url
    assert_response :success
  end

  test "should show friend" do
    get friend_url(@friend)
    assert_response :success
  end

  test "should get edit" do
    get edit_friend_url(@friend)
    assert_response :success
  end

  # --- create -------------------------------------------------------------

  test "should create friend owned by the signed-in user" do
    assert_difference("Friend.count") do
      post friends_url, params: { friend: {
        first_name: "Alan", last_name: "Turing", email: "alan@example.com",
        phone: "555-0300", twitter: "@alan"
      } }
    end

    assert_redirected_to friend_url(Friend.last)
    assert_equal @user, Friend.last.user
  end

  test "ignores a user_id submitted in the form" do
    post friends_url, params: { friend: {
      first_name: "Alan", last_name: "Turing", email: "alan@example.com",
      user_id: users(:two).id
    } }

    assert_equal @user, Friend.last.user
  end

  test "does not create an invalid friend" do
    assert_no_difference("Friend.count") do
      post friends_url, params: { friend: { first_name: "", last_name: "", email: "nope" } }
    end

    assert_response :unprocessable_content
  end

  # --- update / destroy ---------------------------------------------------

  test "should update friend" do
    patch friend_url(@friend), params: { friend: { first_name: "Adele" } }
    assert_redirected_to friend_url(@friend)
    assert_equal "Adele", @friend.reload.first_name
  end

  test "does not apply an invalid update" do
    patch friend_url(@friend), params: { friend: { email: "nope" } }
    assert_response :unprocessable_content
    assert_equal "ada@example.com", @friend.reload.email
  end

  test "should destroy friend" do
    assert_difference("Friend.count", -1) do
      delete friend_url(@friend)
    end

    assert_redirected_to friends_url
  end

  # --- ownership ----------------------------------------------------------

  test "cannot view another user's friend" do
    get friend_url(@others_friend)
    assert_redirected_to friends_url
  end

  test "cannot edit another user's friend" do
    get edit_friend_url(@others_friend)
    assert_redirected_to friends_url
  end

  test "cannot update another user's friend" do
    patch friend_url(@others_friend), params: { friend: { first_name: "Hacked" } }
    assert_redirected_to friends_url
    assert_equal "Grace", @others_friend.reload.first_name
  end

  test "cannot destroy another user's friend" do
    assert_no_difference("Friend.count") do
      delete friend_url(@others_friend)
    end

    assert_redirected_to friends_url
  end

  test "a missing friend redirects instead of raising" do
    get friend_url(id: 999_999)
    assert_redirected_to friends_url
  end

  # --- json ---------------------------------------------------------------

  test "index responds to json" do
    get friends_url(format: :json)
    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 1, payload.size
    assert_equal @friend.email, payload.first["email"]
  end
end
