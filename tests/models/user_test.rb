require_relative '../test_helper'
require_relative '../../models/user'

class UserTest < Minitest::Test
  def test_email_presence
    response = User.new(nil).save
    assert_equal "Email can't be blank", response.first
  end

  def test_invalid_email_format
    response = User.new(nil).save
    assert_equal 'Invalid email format', response.last
    response = User.new('info@com').save
    assert_equal 'Invalid email format', response.last
  end

  def test_valid_email_format
    response = User.new('user1@test.com').save
    assert response.is_a? Integer
  end

  def test_save_with_existing_user_will_return_existing_id
    first_response = User.new('user1@test.com').save
    second_response = User.new('user1@test.com').save
    assert_equal first_response, second_response
  end
end
