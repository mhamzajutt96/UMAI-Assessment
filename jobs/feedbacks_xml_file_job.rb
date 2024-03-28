require_relative '../env'

def execute_command(command)
  `#{command}`
end

def fetch_feedbacks
  command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e 'USE #{DB_NAME}; SELECT * FROM feedbacks;'"
  execute_command(command)
end

def fetch_average_rating(post_id)
  command = "mysql -u #{DB_USERNAME} -h #{DB_HOST} -N -s -e 'USE #{DB_NAME}; " \
            "SELECT AVG(value) FROM ratings WHERE post_id = #{post_id};'"
  execute_command(command)
end

def generate_xml(feedback_data)
  xml_content = "<feedback_list>\n"
  feedback_data.each do |feedback|
    xml_content += "  <feedback>\n"
    xml_content += "    <owner_id>#{feedback[:owner_id]}</owner_id>\n"
    xml_content += "    <comment>#{feedback[:comment]}</comment>\n"
    xml_content += "    <feedback_type>#{feedback[:user_id] == 'NULL' ? 'Post' : 'User'}</feedback_type>\n"
    if feedback[:user_id] == 'NULL'
      average_rating = fetch_average_rating(feedback[:post_id]).strip.to_f
      xml_content += "    <rating>#{average_rating}</rating>\n"
    else
      xml_content += "    <rating>#{nil}</rating>\n"
    end
    xml_content += "  </feedback>\n"
  end
  xml_content + "</feedback_list>"
end

def write_xml_to_file(xml_content)
  File.open('public/feedbacks.xml', 'w') { |file| file.write(xml_content) }
end

def execute_worker
  feedbacks = []
  loop do
    current_time = Time.now
    if current_time.hour == 9 && current_time.min == 0
      feedback_data = fetch_feedbacks
      feedback_data.each_line do |line|
        id, user_id, post_id, comment, owner_id = line.strip.split("\t")
        feedbacks << { id: id, post_id: post_id, user_id: user_id, comment: comment, owner_id: owner_id }
      end
      xml_content = generate_xml(feedbacks)
      write_xml_to_file(xml_content)
    end
    sleep(60)
  end
end

execute_worker
