require "#{File.dirname(__FILE__)}/../test_helper"

class IntegrationOtherTest < ActionController::IntegrationTest
  def test_other
    tester = new_session
    tester.check_index_page
    tester.check_news_page(1, 7)
    tester.check_news_page(2, 5)
    tester.check_tour_page
    tester.check_contact_form
    tester.post_failing_contact_form
    tester.post_valid_contact_form
    tester.cant_access_site_without_logging_in
    tester.cant_access_nonexisting_page
    tester.check_login_redirects_to_requested_page(weights_path, 'weights/index', user_logins(:bob).openid_url)
  end

  module OtherTestDSL
    def assert_news_items(count)
      assert_select "div[class=news-item]", count
    end

    def check_index_page
      get home_path
      assert_success('home/index')
      assert_news_items(3)
    end

    def check_news_page(page, count)
      get news_path if page == 1
      get news_page_path(:page => page) if page > 1
      assert_success('news/index')
      assert_news_items(count)
    end

    def check_tour_page
      get tour_path
      assert_success('home/tour')

      assert_select 'h4', {:minimum => 1}
      assert_select 'a[rel=thumbnail]' do
        assert_select 'img'
      end
    end

    def check_contact_form
      get contact_path
      assert_success('home/contact')

      assert_select 'form[action=?]', contact_path do
        assert_select 'div[class=form-row]', 6
        assert_select 'input[type=submit]', 1
        assert_select 'input[type=text][id=name]', 1
        assert_select 'input[type=text][id=email]', 1
        assert_select 'input[type=text][id=subject]', 1
        assert_select 'select[id=category]', 1
        assert_select 'textarea[id=comment]', 1
      end
    end

    def post_failing_contact_form
      post contact_path
      assert_success('home/contact')

      assert_flash_item('error', 'Please enter your name.')
      assert_flash_item('error', 'Please enter a valid email.')
      assert_flash_item('error', 'Please enter a subject.')
      assert_flash_item('error', 'Please tell us what is on your mind.')
    end

    def post_valid_contact_form
      post contact_path, {:name => 'Spidah', :email => 'spidahman@gmail.com', :subject => 'Test', :category => 'other', :comment => 'Test'}
      assert_and_follow_redirect(home_path, 'home/index')
      assert_flash('info', 'Thank you for contacting us. Your comments will be read and a reply sent if needed.', nil)
    end

    def cant_access_site_without_logging_in
      get weights_path
      assert_and_follow_redirect(login_path, 'sessions/new')

      get measurements_path
      assert_and_follow_redirect(login_path, 'sessions/new')

      get targetweights_path
      assert_and_follow_redirect(login_path, 'sessions/new')
    end

    def cant_access_nonexisting_page
      get 'home/foofoo'
      assert_success('home/index')
      assert_flash('error', 'That page could not be found.')
    end

    def check_login_redirects_to_requested_page(page, template, openid_url)
      get page
      assert_and_follow_redirect(login_path, 'sessions/new')
      post session_path, :openid_url => openid_url
      get session_path, :openid_url => openid_url, :open_id_complete => 1
      assert_and_follow_redirect(page, template)
    end
  end

  def new_session
    open_session do |session|
      session.extend(OtherTestDSL)
      yield session if block_given?
    end
  end
end
