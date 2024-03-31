puts 'Seeds Execution is starting!'

NUM_POSTS = 200_000
POSTS_CHUNK_SIZE = 13_000
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
  values = []
  feedback_tracker = Hash.new { |hash, key| hash[key] = Set.new }
  num_feedback.times do
    post_id = post_ids.sample
    comment = generate_random_text(50)
    owner_id = user_ids.sample
    unless feedback_tracker[post_id].include?(owner_id)
      feedback_tracker[post_id].add(owner_id)
      values << [post_id, comment, owner_id]
    end
  end
  columns = %w[post_id comment owner_id]
  bulk_insert('feedbacks', columns, values)
end

def generate_user_feedback(num_feedback, user_ids)
  values = []
  feedback_tracker = Hash.new { |hash, key| hash[key] = Set.new }
  num_feedback.times do
    user_id = user_ids.sample
    comment = generate_random_text(50)
    owner_id = user_ids.sample
    unless feedback_tracker[user_id].include?(owner_id)
      feedback_tracker[user_id].add(owner_id)
      values << [user_id, comment, owner_id]
    end
  end
  columns = %w[user_id comment owner_id]
  bulk_insert('feedbacks', columns, values)
end

def bulk_insert(table, columns, values)
  columns_str = columns.join(', ')
  case table
  when 'users'
    values_str = values.map { |row| "(#{row.join(', ')})" }.join(', ')
  else
    values_str = values.map do |row|
      "(#{row.map.with_index { |value, index| integer_column?(columns[index]) ? value : "'#{value}'" }.join(', ')})"
    end.join(', ')
  end
  query = "INSERT INTO #{table} (#{columns_str}) VALUES #{values_str};"
  system("mysql -u #{DB_USERNAME} -h #{DB_HOST} -e \"USE #{DB_NAME}; #{query}\"")
end

def integer_column?(column_name)
  column_name.end_with?('_id')
end

ips = generate_random_ips(NUM_IPS)

emails = (1..NUM_USERS).map { generate_random_email }
columns = ['email']
values = emails.map { |email| ["'#{email}'"] }
bulk_insert('users', columns, values)
puts 'Users seeds data generated successfully.'

posts = (1..NUM_POSTS).map do
  title = generate_random_text(10)
  content = generate_random_text(100)
  author_id = rand(1..NUM_USERS)
  ip_address = ips.sample
  author_login = generate_random_text(8)
  [title, content, author_id, ip_address, author_login]
end

columns = %w[title content author_id author_ip author_login]
post_chunks = posts.each_slice(POSTS_CHUNK_SIZE).to_a
post_chunks.each do |chunk|
  bulk_insert('posts', columns, chunk)
end
puts 'Posts seeds data generated successfully.'

user_ids = generate_random_user_ids(NUM_USERS)
post_ids = generate_random_post_ids(NUM_POSTS)
#
generate_post_feedback(NUM_POST_FEEDBACK, user_ids, post_ids)
puts 'Posts feedbacks seeds data generated successfully.'

generate_user_feedback(NUM_USER_FEEDBACK, user_ids)
puts 'Users feedbacks seeds data generated successfully.'

puts 'Seeds Execution is completed!'
