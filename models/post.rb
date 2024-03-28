require_relative 'user'

class Post
  attr_accessor :title, :content, :author_ip, :author_login
  attr_reader :user_email
  
  def initialize(user_email, title, content, author_ip, author_login)
    @user_email = user_email
    @title = title
    @content = content
    @author_ip = author_ip
    @author_login = author_login
  end

  def save
    return { errors: ['Title and content cannot be empty'], status: 422 } unless valid_title? && valid_content?
    user_response = User.new(user_email).save
    if user_response.is_a?(Integer) && user_response != 0
      command = "mysql -u #{DB_USERNAME} -N -s -e 'USE #{DB_NAME}; INSERT INTO posts (title, content, author_id, author_ip, author_login) VALUES (\"#{title}\", \"#{content}\", \"#{user_response}\", \"#{author_ip}\", \"#{author_login}\"); SELECT LAST_INSERT_ID();'"
      post_response = `#{command}`.strip.to_i
      {
        status: 200,
        post: { id: post_response, title: title, content: content, author_ip: author_ip, author_login: author_login },
        user: {
          id: user_response,
          email: user_email
        }
      } if post_response != 0
    else
      { user: { errors: user_response }, status: 422 }
    end
  end

  class << self
    def get_top_posts_by_average_rating(limit=100)
      command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
        "SELECT posts.id, posts.title, posts.content, AVG(ratings.value) AS average_rating " \
        "FROM posts " \
        "LEFT JOIN ratings ON posts.id = ratings.post_id " \
        "GROUP BY posts.id " \
        "ORDER BY average_rating DESC " \
        "LIMIT #{limit};\""

      result = `#{command}`
      parse_result(result)
    end

    def get_ips_with_authors
      posts = []
      command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e \"USE #{DB_NAME}; " \
                "SELECT posts.author_ip, posts.author_login FROM posts;\""
      result = `#{command}`
      result.each_line do |line|
        author_ip, author_login = line.strip.split("\t")
        posts << { author_ip: author_ip, author_login: author_login }
      end
      ip_authors_map = Hash.new { |hash, key| hash[key] = [] }
      posts.each do |post|
        ip_authors_map[post[:author_ip]] << post[:author_login]
      end
      { status: 200, authors_ip: ip_authors_map }
    end

    private

    def parse_result(result)
      top_posts = []
      result.each_line do |line|
        post_id, title, content, average_rating = line.strip.split("\t")
        top_posts << { id: post_id.to_i, title: title, content: content, average_rating: average_rating.to_f }
      end
      { status: 200, posts: top_posts }
    end
  end

  private

  def valid_title?
    !title.nil? && !title.empty?
  end

  def valid_content?
    !content.nil? && !content.empty?
  end
end
