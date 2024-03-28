puts 'Seeds Execution is starting!'

NUM_POSTS = 200_000
NUM_USERS = 100
NUM_IPS = 50

NUM_POST_FEEDBACK = 10_000
NUM_USER_FEEDBACK = 50

def generate_random_text(length)
  ('a'..'z').to_a.sample(length).join
end

def generate_random_ips(num_ips)
  (1..num_ips).map do
    (0...4).map { rand(256) }.join('.')
  end
end

def generate_random_email
  prefix = generate_random_text(8)
  domain = generate_random_text(8)
  "#{prefix}@#{domain}.com"
end

def generate_random_user_ids(num_users)
  (1..num_users).to_a.sample(num_users)
end

def generate_random_post_ids(num_posts)
  (1..num_posts).to_a.sample(num_posts)
end

def generate_post_feedback(num_feedback, user_ids, post_ids)
  feedback_tracker = Hash.new { |hash, key| hash[key] = Set.new }
  num_feedback.times do
    post_id = post_ids.sample
    comment = generate_random_text(50)
    owner_id = user_ids.sample
    unless feedback_tracker[post_id].include?(owner_id)
      feedback_tracker[post_id].add(owner_id)
      system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e \"USE #{DB_NAME}; INSERT INTO feedbacks (post_id, comment, owner_id) VALUES ('#{post_id}', '#{comment}', '#{owner_id}');\"")
    end
  end
end

def generate_user_feedback(num_feedback, user_ids)
  feedback_tracker = Hash.new { |hash, key| hash[key] = Set.new }
  num_feedback.times do
    user_id = user_ids.sample
    comment = generate_random_text(50)
    owner_id = user_ids.sample
    unless feedback_tracker[user_id].include?(owner_id)
      feedback_tracker[user_id].add(owner_id)
      system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e \"USE #{DB_NAME}; INSERT INTO feedbacks (user_id, comment, owner_id) VALUES ('#{user_id}', '#{comment}', '#{owner_id}');\"")
    end
  end
end

ips = generate_random_ips(NUM_IPS)

NUM_USERS.times do
  email = generate_random_email
  system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e \"USE #{DB_NAME}; INSERT INTO users (email) VALUES ('#{email}');\"")
end
puts 'Users seeds data generated successfully.'

NUM_POSTS.times do
  title = generate_random_text(10)
  content = generate_random_text(100)
  author_id = (1..NUM_USERS).to_a.sample
  ip_address = ips.sample
  author_login = generate_random_text(8)
  system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e \"USE #{DB_NAME}; INSERT INTO posts (title, content, author_id, author_ip, author_login) VALUES ('#{title}', '#{content}', #{author_id}, '#{ip_address}', '#{author_login}');\"")
end
puts 'Posts seeds data generated successfully.'

user_ids = generate_random_user_ids(NUM_USERS)
post_ids = generate_random_post_ids(NUM_POSTS)

generate_post_feedback(NUM_POST_FEEDBACK, user_ids, post_ids)
puts 'Posts feedbacks seeds data generated successfully.'

generate_user_feedback(NUM_USER_FEEDBACK, user_ids)
puts 'Users feedbacks seeds data generated successfully.'

puts 'Seeds Execution is completed!'
