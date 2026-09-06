require "test_helper"

class FriendTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  def build_friend(attributes = {})
    @user.friends.build({
      first_name: "Alan",
      last_name: "Turing",
      email: "alan@example.com",
      phone: "555-0300",
      twitter: "@alan"
    }.merge(attributes))
  end

  test "a fully populated friend is valid" do
    assert build_friend.valid?
  end

  test "requires a first name" do
    friend = build_friend(first_name: "")
    assert_not friend.valid?
    assert_includes friend.errors[:first_name], "can't be blank"
  end

  test "requires a last name" do
    friend = build_friend(last_name: "")
    assert_not friend.valid?
    assert_includes friend.errors[:last_name], "can't be blank"
  end

  test "requires an email address" do
    friend = build_friend(email: "")
    assert_not friend.valid?
    assert_includes friend.errors[:email], "can't be blank"
  end

  test "rejects a malformed email address" do
    friend = build_friend(email: "not-an-email")
    assert_not friend.valid?
    assert_includes friend.errors[:email], "is not a valid email address"
  end

  test "requires an owner" do
    friend = Friend.new(first_name: "Alan", last_name: "Turing", email: "alan@example.com")
    assert_not friend.valid?
    assert_includes friend.errors[:user], "must exist"
  end

  test "phone and twitter are optional" do
    assert build_friend(phone: "", twitter: "").valid?
  end

  test "full_name joins first and last name" do
    assert_equal "Alan Turing", build_friend.full_name
  end

  test "search matches a partial name, case insensitively" do
    assert_includes Friend.search("lovel"), friends(:one)
    assert_includes Friend.search("ADA"), friends(:one)
  end

  test "search matches email, phone and twitter" do
    assert_includes Friend.search("ada@example.com"), friends(:one)
    assert_includes Friend.search("555-0100"), friends(:one)
    assert_includes Friend.search("@ada"), friends(:one)
  end

  test "search excludes records that do not match" do
    assert_not_includes Friend.search("lovel"), friends(:two)
  end

  test "blank search returns everything in the current scope" do
    assert_equal @user.friends.count, @user.friends.search("").count
    assert_equal @user.friends.count, @user.friends.search(nil).count
  end

  test "search stays scoped to the relation it is chained onto" do
    assert_not_includes @user.friends.search("Hopper"), friends(:two)
  end

  test "search treats LIKE wildcards as literal characters" do
    assert_empty Friend.search("%")
  end
end
