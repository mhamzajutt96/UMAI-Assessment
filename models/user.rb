class User
  attr_accessor :email
  attr_reader :errors
  
  def initialize(email)
    @email = email
    @errors = []
    valid?
  end

  def save
    return errors unless errors.empty?
    existing_user_id = find_user_by_email
    return existing_user_id if existing_user_id != 0
    create_user_in_database
  end

  private

  def valid?
    validate_email_presence
    validate_email_format
  end

  def validate_email_presence
    errors.push("Email can't be blank") if email.nil? || email.empty?
  end

  def validate_email_format
    unless email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      errors.push('Invalid email format')
    end
  end

  def find_user_by_email
    command = "mysql -u #{DB_USERNAME} -N -s -e 'USE #{DB_NAME}; SELECT * FROM users WHERE email = \"#{email}\" LIMIT 1;'"
    `#{command}`.strip.to_i
  end

  def create_user_in_database
    command = "mysql -u #{DB_USERNAME} -N -s -e 'USE #{DB_NAME}; INSERT INTO users (email) VALUES (\"#{email}\"); SELECT LAST_INSERT_ID();'"
    `#{command}`.strip.to_i
  end
end
