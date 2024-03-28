require_relative '../../../test_helper'
require_relative '../../../../models/post'
require_relative '../../../../models/rating'
require_relative '../../../../controllers/api/v1/posts_controller'
require 'json'

module Api
  module V1
    class PostsControllerTest < Minitest::Test
      def setup
        @controller = Api::V1::PostsController.new
      end

      def test_index_method
        request_body = { limit: 10 }.to_json
        status, response_body = @controller.index(request_body)
        assert_equal 200, status
        assert_instance_of Hash, JSON.parse(response_body)
      end

      def test_create_method
        post_data = {
          user_email: 'test@example.com',
          title: 'Test Post',
          content: 'This is a test post',
          author_ip: '127.0.0.1',
          author_login: 'test_author'
        }
        request_body = post_data.to_json
        status, response_body = @controller.create(request_body)
        assert_equal 200, status
        assert_instance_of Hash, JSON.parse(response_body)
      end

      def test_rate_post_method
        rating_data = {
          post_id: 1,
          value: 4
        }
        request_body = rating_data.to_json
        status, response_body = @controller.rate_post(request_body)
        assert_equal 200, status
        assert_instance_of Hash, JSON.parse(response_body)
      end

      def test_get_ips_with_authors_method
        status, response_body = @controller.get_ips_with_authors
        assert_equal 200, status
        assert_instance_of Hash, JSON.parse(response_body)
      end
    end
  end
end
