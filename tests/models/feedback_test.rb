require_relative '../test_helper'
require_relative '../../models/feedback'

class FeedbackTest < Minitest::Test
  def setup
    @user_id = 1
    @post_id = 1
    @comment = "Test comment"
    @owner_id = 1
    @existing_feedback = "1\t1\t1\tTest comment\t1\n"
  end

  def test_valid_feedback_creation
    feedback = Feedback.new(@user_id, nil, @comment, @owner_id)
    response = feedback.save
    assert_equal 200, response[:status], 'Response status should be 200 for valid feedback creation'
  end

  def test_invalid_feedback_creation_both_present
    feedback = Feedback.new(@user_id, @post_id, @comment, @owner_id)
    response = feedback.save
    assert_equal 422, response[:status], 'Response status should be 422 for invalid feedback creation'
    assert_includes response[:errors], 'Post ID and User ID cannot be present together!', 'Error message should indicate both cannot be present'
  end

  def test_invalid_feedback_creation_neither_present
    feedback = Feedback.new(nil, nil, @comment, @owner_id)
    response = feedback.save
    assert_equal 422, response[:status], 'Response status should be 422 for invalid feedback creation'
    assert_includes response[:errors], 'Post ID or User ID must be present!', 'Error message should indicate one of them must be present'
  end

  def test_invalid_feedback_creation_owner_id_missing
    feedback = Feedback.new(@user_id, nil, @comment, nil)
    response = feedback.save
    assert_equal 422, response[:status], 'Response status should be 422 for invalid feedback creation'
    assert_includes response[:errors], 'Owner ID must be present!', 'Error message should indicate owner_id is missing'
  end

  def test_existing_feedback_creation
    feedback = Feedback.new(@user_id, nil, @comment, @owner_id)
    response = feedback.save
    assert_equal 200, response[:status], 'Response status should be 200 for existing feedback creation'
    assert_equal true, response[:feedback_already_exists], 'Feedback should already exist'
  end

  def test_get_feedback_list
    response = Feedback.get_feedback_list(@existing_feedback, @owner_id)
    assert_equal 200, response[:status], 'Response status should be 200 for getting feedback list'
    assert response[:feedbacks].is_a? Array
    assert response[:current_feedback].is_a? Hash
  end
end