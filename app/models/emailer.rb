class Emailer < ActionMailer::Base
  def contact_form(name, email, subject, category, comment)
    subject "[Healtheriser - #{category}] #{subject}"
    recipients 'spidahman@gmail.com'
    new_from = "#{name} <#{email}>"
    from new_from
    body :subject => subject, :from => new_from, :comment => comment.sanitize.strip_tags, :sent_on => Time.now
  end
end
