require 'digest/sha1'
class UserLogin < ActiveRecord::Base
  belongs_to :user

  # Virtual attribute for the unencrypted password
  attr_accessor :loginname, :password
  attr_accessible :openid_url, :user_id, :linked_to

  validates_presence_of :openid_url, :if => :openid_login?, :message => 'Enter a valid OpenID URL.'
  validates_presence_of :user_id, :if => :openid_login?, :message => 'Enter a valid user account id.'
  validates_presence_of :linked_to, :if => :openid_login?, :message => 'Enter a valid linked account id or 0 for a real account.'

  validates_presence_of :password, :if => :password_required?, :message => 'Please enter a password.'
  validates_presence_of :password_confirmation, :if => :password_required?, :message => 'Please confirm your password.'
  validates_length_of :password, :within => 4..40, :if => :password_required?,
    :too_short => 'Please pick a password between 4 and 40 characters long.',
    :too_long => 'Please pick a password between 4 and 40 characters long.'
  validates_confirmation_of :password, :if => :password_required?, :message => 'Please confirm your password correctly.'
  before_save :encrypt_password

  # find an openid login using the openid_url
  def self.get(openid_url)
    find(:first, :conditions => {:openid_url => openid_url})
  end

  def self.find_normal_login(user)
    find(:first, :conditions => {:openid_url => nil, :user_id => user.id})
  end

  def self.find_openid_login(user)
    find(:all, :conditions => {:crypted_password => nil, :user_id => user.id})
  end
  
  def self.admin_pagination(page)
    paginate :page => page, :per_page => 20, :order => 'user_logins.user_id ASC, user_logins.id ASC', :include => :user
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(user_id, password)
    ul = find(:first, :conditions => {:user_id => user_id, :openid_url => nil}) # need to get the salt
    ul && ul.authenticated?(password) ? ul : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self[:salt] = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{loginname}--")
      self[:crypted_password] = encrypt(password)
    end

    def openid_login?
      !openid_url.blank?
    end

    def normal_login?
      openid_url.blank?
    end

    def password_required?
      normal_login? && (crypted_password.blank? || !password.blank?)
    end
end
