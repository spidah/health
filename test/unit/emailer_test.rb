require File.dirname(__FILE__) + '/../test_helper'

class EmailerTest < ActionMailer::TestCase
  tests Emailer
  def test_contact_form
    #@expected.subject = 'Emailer#contact_form'
    #@expected.body    = read_fixture('contact_form')
    #@expected.date    = Time.now

    #assert_equal @expected.encoded, Emailer.create_contact_form(@expected.date).encoded
  end

end
