require_relative '../test_helper'
require_relative '../../models/post'
require_relative '../../models/rating'

class PostTest < Minitest::Test
  def setup
    @post = Post.new("user1@test.com", "Some Title", "Some Content", "127.0.0.1", "authorusername")
  end

  def test_save_with_invalid_title
    @post.title = nil
    assert_equal({ errors: ["Title and content cannot be empty"], status: 422 }, @post.save)
  end

  def test_save_with_invalid_content
    @post.content = nil
    assert_equal({ errors: ["Title and content cannot be empty"], status: 422 }, @post.save)
  end

  def test_save_with_valid_data
    response = @post.save
    assert_equal 200, response[:status]
    assert response[:post][:id] != 0
    assert @post.title, response[:post][:title]
    assert @post.content, response[:post][:content]
    assert @post.author_ip, response[:post][:author_ip]
    assert @post.author_login, response[:post][:author_login]
  end

  def test_get_top_posts_by_average_rating
    post1 = @post.save
    Rating.new(post1[:post][:id], 5).save
    post2 = Post.new("user2@test.com", "Other Title", "Other Content", "127.0.0.2", "authorotherusername").save
    Rating.new(post2[:post][:id], 3).save
    response = Post.get_top_posts_by_average_rating(1)
    assert_equal 200, response[:status]
    assert_equal 1, response[:posts].size
    response = Post.get_top_posts_by_average_rating
    assert response[:posts].size > 1
    assert_equal 5, response[:posts].first[:average_rating]
    Rating.new(post1[:post][:id], 1).save
    Rating.new(post1[:post][:id], 2).save
    response = Post.get_top_posts_by_average_rating
    assert_equal 3, response[:posts].first[:average_rating]
  end

  def test_get_ips_with_authors
    @post.save
    Post.new("user2@test.com", "Other Title", "Other Content", "127.0.0.2", "authorotherusername").save
    response = Post.get_ips_with_authors
    assert_equal 200, response[:status]
    assert response[:authors_ip].is_a? Hash
    assert_equal 'authorusername', response[:authors_ip]["#{@post.author_ip}"].first
  end
end