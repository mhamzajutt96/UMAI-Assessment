require_relative '../../../test_helper'
require_relative '../../../../models/feedback'
require_relative '../../../../controllers/api/v1/feedbacks_controller'
require 'json'

module Api
  module V1
    class FeedbacksControllerTest < Minitest::Test
      def setup
        @controller = Api::V1::FeedbacksController.new
      end

      def test_create_feedback_with_invalid_data
        feedback_data = {
          comment: 'Great post!',
          owner_id: 1
        }
        request_body = feedback_data.to_json
        status, response_body = @controller.create(request_body)
        assert_equal 422, status
        assert_instance_of Hash, JSON.parse(response_body)
        assert_includes JSON.parse(response_body)['errors'], 'Post ID or User ID must be present!'
      end

      def test_create_feedback_with_post_id_and_user_id
        feedback_data = {
          user_id: 1,
          post_id: 1,
          comment: 'Great post!',
          owner_id: 1
        }
        request_body = feedback_data.to_json
        status, response_body = @controller.create(request_body)
        assert_equal 422, status
        assert_instance_of Hash, JSON.parse(response_body)
        assert_includes JSON.parse(response_body)['errors'], 'Post ID and User ID cannot be present together!'
      end

      def test_create_feedback_without_owner_id
        feedback_data = {
          post_id: 1,
          comment: 'Great post!'
        }
        request_body = feedback_data.to_json
        status, response_body = @controller.create(request_body)
        assert_equal 422, status
        assert_instance_of Hash, JSON.parse(response_body)
        assert_includes JSON.parse(response_body)['errors'], 'Owner ID must be present!'
      end

      def test_create_feedback_with_valid_data
        feedback_data = {
          post_id: 1,
          comment: 'Great post!',
          owner_id: 1
        }
        request_body = feedback_data.to_json
        status, response_body = @controller.create(request_body)
        assert_equal 200, status
        assert_instance_of Hash, JSON.parse(response_body)
      end
    end
  end
end
