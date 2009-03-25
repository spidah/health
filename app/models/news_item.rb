class NewsItem < ActiveRecord::Base
  validates_presence_of :title, :message => 'Please enter a title for the news item.'
  validates_presence_of :body, :message => 'Please enter a body for the news item.'
  validates_presence_of :posted_on, :message => 'Please enter a date for the news item.'

  def self.pagination(page, per_page = 7)
    paginate :page => page, :per_page => per_page, :order => 'posted_on DESC, id DESC'
  end
end
