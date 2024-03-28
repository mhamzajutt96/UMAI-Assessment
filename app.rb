require 'socket'
require_relative 'env'

puts 'Initializing.........!'
puts 'Program Execution is Starting.........!'
puts 'Executing the Test Cases.........!'
puts 'Executing the Test Cases of User Model.........!'
system('ruby tests/models/user_test.rb')
puts 'Executing the Test Cases of Post Model.........!'
system('ruby tests/models/post_test.rb')
puts 'Executing the Test Cases of Rating Model.........!'
system('ruby tests/models/rating_test.rb')
puts 'Executing the Test Cases of Feedback Model.........!'
system('ruby tests/models/feedback_test.rb')
puts 'Executing the Test Cases of Posts Controller.........!'
system('ruby tests/controllers/api/v1/posts_controller_test.rb')
puts 'Executing the Test Cases of Feedbacks Controller.........!'
system('ruby tests/controllers/api/v1/feedbacks_controller_test.rb')
puts 'Tests Execution is completed.........!'

require_relative 'db'
require_relative 'seeds'
require_relative 'controllers/api/v1/posts_controller'
require_relative 'controllers/api/v1/feedbacks_controller'

puts 'Running the worker for Feedback xml file generator!.........!'
system('ruby jobs/feedbacks_xml_file_job.rb')
puts 'XML generation completed!'

puts 'Starting the Server!'

server = TCPServer.new('localhost', 3000)

posts_controller = Api::V1::PostsController.new
feedbacks_controller = Api::V1::FeedbacksController.new

puts "Server is running on http://localhost:3000"

loop do
  Thread.start(server.accept) do |client|
    request_line = client.gets
    next if !request_line

    method, path, _ = request_line.split
    headers = {}
    while (line = client.gets)
      break if line == "\r\n"
      key, value = line.split(': ')
      headers[key] = value.chomp
    end
    content_length = headers['Content-Length'].to_i
    request_body = client.read(content_length)

    puts "Received request with path: #{path} and method: #{method}"

    case [method, path]
    when %w[POST /posts]
      status, response_body = posts_controller.create(request_body)
    when %w[POST /rate_post]
      status, response_body = posts_controller.rate_post(request_body)
    when %w[GET /get_top_posts_by_average_rating]
      status, response_body = posts_controller.index(request_body)
    when %w[GET /get_ips_with_authors]
      status, response_body = posts_controller.get_ips_with_authors
    when %w[POST /feedbacks]
      status, response_body = feedbacks_controller.create(request_body)
    else
      status = 404
      response_body = { error: 'Route not found' }.to_json
    end

    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts response_body

    client.close
  end
end
