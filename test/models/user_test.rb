require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires an email address" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires a unique email address" do
    user = User.new(email: users(:one).email, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires a password of at least six characters" do
    user = User.new(email: "new@example.com", password: "12345")
    assert_not user.valid?
    assert_not_empty user.errors[:password]
  end

  test "stores the password hashed, never in plain text" do
    user = User.create!(email: "hashed@example.com", password: "password123")
    assert_not_equal "password123", user.encrypted_password
    assert user.valid_password?("password123")
  end

  test "owns its own friends" do
    assert_includes users(:one).friends, friends(:one)
    assert_not_includes users(:one).friends, friends(:two)
  end
end
