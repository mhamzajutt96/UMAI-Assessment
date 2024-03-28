class Feedback
  attr_accessor :user_id, :post_id, :comment, :owner_id

  def initialize(user_id, post_id, comment, owner_id)
    @user_id = user_id
    @post_id = post_id
    @comment = comment
    @owner_id = owner_id
  end

  def save
    return { status: 422, errors: ['Post ID or User ID must be present!'] } if post_id.nil? && user_id.nil?
    return { status: 422, errors: ['Post ID and User ID cannot be present together!'] } if !post_id.nil? && !user_id.nil?
    return { status: 422, errors: ['Owner ID must be present!'] } if owner_id.nil?
    existing_feedback = find_existing_feedback
    return existing_feedback if existing_feedback[:feedback_already_exists]
    insert_feedback
  end

  class << self
    def get_feedback_list(current_feedback, owner_id)
      result = get_feedback_list_from_database(owner_id)
      parse_result(result, current_feedback)
    end

    private

    def get_feedback_list_from_database(owner_id)
      command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
        "SELECT * FROM feedbacks WHERE owner_id = '#{owner_id}' ORDER BY created_at DESC;\""
      `#{command}`
    end

    def parse_result(result, feedback)
      feedbacks = []
      result.each_line do |line|
        id, user_id, post_id, comment, owner_id = line.strip.split("\t")
        feedbacks << { id: id, post_id: post_id, user_id: user_id, comment: comment, owner_id: owner_id }
      end
      id, user_id, post_id, comment, owner_id = feedback.split("\t")
      feedback = { id: id, post_id: post_id, user_id: user_id, comment: comment, owner_id: owner_id }
      { status: 200, current_feedback: feedback, feedbacks: feedbacks.reject { |f| f[:id] == feedback[:id] } }
    end
  end

  private

  def find_existing_feedback
    command = if post_id.nil? || post_id == ''
                "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
                "SELECT * FROM feedbacks WHERE user_id = '#{user_id}' AND owner_id = '#{owner_id}' LIMIT 1;\""
              else
                "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
                "SELECT * FROM feedbacks WHERE post_id = '#{post_id}' AND owner_id = '#{owner_id}' LIMIT 1;\""
              end
    output = `#{command}`
    output.empty? ? { status: 200, feedback_already_exists: false } : { status: 200, feedback_already_exists: true, feedback: output.strip }
  end

  def insert_feedback
    command = if post_id.nil? || post_id == ''
                "mysql -u #{DB_USERNAME} -h #{DB_HOST} -e \"USE #{DB_NAME}; " \
                "INSERT INTO feedbacks (user_id, comment, owner_id) VALUES ('#{user_id}', '#{comment}', '#{owner_id}');\""
              else
                "mysql -u #{DB_USERNAME} -h #{DB_HOST} -e \"USE #{DB_NAME}; " \
                "INSERT INTO feedbacks (post_id, comment, owner_id) VALUES ('#{post_id}', '#{comment}', '#{owner_id}');\""
              end
    system(command)
    find_existing_feedback
  end
end
