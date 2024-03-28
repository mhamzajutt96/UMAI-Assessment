puts "Executing the Database Commands.........!"

# Drop the database
system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e 'DROP DATABASE IF EXISTS #{DB_NAME}'")
puts "Database dropped successfully if exists, So the seeds/tests file will not generate duplicate data"

system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e 'CREATE DATABASE #{DB_NAME}'")
puts "Database created successfully."

# Define SQL queries to create tables
sql_queries = [
  "USE #{DB_NAME}",
  "CREATE TABLE IF NOT EXISTS #{DB_NAME}.users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE
  )",
  "CREATE TABLE IF NOT EXISTS #{DB_NAME}.posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id INT,
    author_ip VARCHAR(255) NOT NULL,
    author_login VARCHAR(255) NOT NULL,
    FOREIGN KEY (author_id) REFERENCES #{DB_NAME}.users(id)
  )",
  "CREATE TABLE IF NOT EXISTS #{DB_NAME}.ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value INT NOT NULL CHECK (value >= 1 AND value <= 5),
    post_id INT,
    FOREIGN KEY (post_id) REFERENCES #{DB_NAME}.posts(id)
  )",
  "CREATE TABLE IF NOT EXISTS #{DB_NAME}.feedbacks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    comment TEXT,
    owner_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
  )"
]

# Create database and tables
sql_queries.each do |sql_query|
  system("mysql -u#{DB_USERNAME} -h#{DB_HOST} -e '#{sql_query}' #{DB_NAME}")
end

puts "Tables created successfully."
