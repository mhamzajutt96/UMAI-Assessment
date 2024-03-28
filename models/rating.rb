class Rating
  attr_accessor :value
  attr_reader :post_id, :errors

  def initialize(post_id, value)
    @post_id = post_id
    @value = value
    @errors = []
    validate_rating_value
  end

  def save
    return { rating: { errors: errors }, status: 422 } unless errors.empty?
    command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -e \"USE #{DB_NAME}; " \
              "INSERT INTO ratings (post_id, value) VALUES ('#{post_id}', '#{value}');\""
    response = system(command)
    if response
      command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
        "SELECT AVG(value) FROM ratings WHERE post_id = '#{post_id}';\""
      average_rating = `#{command}`.to_f
      { status: 200, post: { id: post_id, average_rating: average_rating } }
    else
      { errors: 'There is an error in creating the rating', status: 200 }
    end
  end

  private

  def validate_rating_value
    errors.push('Rating value out of Range') unless (1..5).to_a.include?(value)
  end
end
