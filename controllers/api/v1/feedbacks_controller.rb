require_relative '../../../models/feedback'
require 'json'

module Api
  module V1
    class FeedbacksController
      def create(request_body)
        feedback_data = JSON.parse(request_body)
        feedback = Feedback.new(
          feedback_data['user_id'], feedback_data['post_id'], feedback_data['comment'], feedback_data['owner_id']
        )
        response = feedback.save
        if response[:status] == 200
          current_feedback = response[:feedback]
          feedbacks = Feedback.get_feedback_list(current_feedback, feedback_data['owner_id'])
          [feedbacks[:status], feedbacks.to_json]
        else
          [response[:status], response.to_json]
        end
      rescue JSON::ParserError => e
        [400, { error: 'Invalid JSON format', message: e.message }.to_json]
      end
    end
  end
end
