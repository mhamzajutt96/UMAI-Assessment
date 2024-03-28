require_relative '../../../models/post'
require_relative '../../../models/rating'
require 'json'

module Api
  module V1
    class PostsController
      def index(request_body)
        data = JSON.parse(request_body)
        posts = Post.get_top_posts_by_average_rating(data['limit'])
        [posts[:status], posts.to_json]
      rescue JSON::ParserError => e
        [400, { error: 'Invalid JSON format', message: e.message }.to_json]
      end

      def create(request_body)
        post_data = JSON.parse(request_body)
        post = Post.new(post_data['user_email'], post_data['title'], post_data['content'], post_data['author_ip'], post_data['author_login'])
        result = post.save
        [result[:status], result.to_json]
      rescue JSON::ParserError => e
        [400, { error: 'Invalid JSON format', message: e.message }.to_json]
      end

      def rate_post(request_body)
        rating_data = JSON.parse(request_body)
        rating = Rating.new(rating_data['post_id'], rating_data['value'])
        result = rating.save
        [result[:status], result.to_json]
      rescue JSON::ParserError => e
        [400, { error: 'Invalid JSON format', message: e.message }.to_json]
      end

      def get_ips_with_authors
        result = Post.get_ips_with_authors
        [result[:status], result.to_json]
      rescue JSON::ParserError => e
        [400, { error: 'Invalid JSON format', message: e.message }.to_json]
      end
    end
  end
end
