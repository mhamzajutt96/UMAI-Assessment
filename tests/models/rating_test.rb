require_relative '../test_helper'
require_relative '../../models/rating'

class RatingTest < Minitest::Test
  def setup
    @post_id = 1
    @value = 4
  end

  def test_valid_rating_creation
    rating = Rating.new(@post_id, @value)
    assert_equal([], rating.errors, 'Rating should have no errors')
  end

  def test_invalid_rating_creation
    invalid_value = 6
    rating = Rating.new(@post_id, invalid_value)
    assert_includes rating.errors, 'Rating value out of Range', 'Rating should have an error for invalid value'
  end

  def test_save_method_success
    rating = Rating.new(@post_id, @value)
    response = rating.save
    assert_equal 200, response[:status], 'Response status should be 200 for successful save'
    assert_instance_of Float, response[:post][:average_rating], 'Average rating should be a float'
  end
end