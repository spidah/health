require File.dirname(__FILE__) + '/../test_helper'

class NewsItemTest < Test::Unit::TestCase
  def test_should_create_news_item
    assert_difference NewsItem, :count do
      ni = create_news_item(:title => 'News Item', :body => 'News Item', :posted_on => Date.today)
      assert !ni.new_record?, "#{ni.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_title
    assert_no_difference NewsItem, :count do
      ni = create_news_item(:body => 'News Item', :posted_on => Date.today)
      assert ni.errors.on(:title)
    end
  end

  def test_should_require_body
    assert_no_difference NewsItem, :count do
      ni = create_news_item(:title => 'News Item', :posted_on => Date.today)
      assert ni.errors.on(:body)
    end
  end

  def test_should_require_posted_on
    assert_no_difference NewsItem, :count do
      ni = create_news_item(:title => 'News Item', :body => 'News Item')
      assert ni.errors.on(:posted_on)
    end
  end

  def test_should_return_pagination
    news_items = NewsItem.pagination(1)
    assert news_items
    assert_equal 7, news_items.size

    news_items = NewsItem.pagination(2)
    assert news_items
    assert_equal 5, news_items.size
  end

  def test_should_update
    ni = create_news_item(:title => 'News Item', :body => 'News Item', :posted_on => Date.today)
    assert_equal 'News Item', ni.title
    assert_equal 'News Item', ni.body
    assert Date.today, ni.posted_on

    ni.update_attributes(:title => 'New News Item', :body => 'New News Item', :posted_on => Date.tomorrow)
    ni.reload
    assert_equal 'New News Item', ni.title
    assert_equal 'New News Item', ni.body
    assert_equal Date.tomorrow, ni.posted_on
  end

  def test_should_destroy
    ni = create_news_item(:title => 'News Item', :body => 'News Item', :posted_on => Date.today)
    ni.destroy
    assert_raise(ActiveRecord::RecordNotFound) {NewsItem.find(ni.id)}
  end

  protected
    def create_news_item(params)
      NewsItem.create(params)
    end
end
