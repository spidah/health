class User < ActiveRecord::Base
  has_many :weights
  has_many :target_weights
  has_many :measurements
  has_many :meals
  has_many :foods

  # 0.393700 inches to a cm
  # 2.204622 lbs to a kg

  # only allow these attributes to be changeable
  attr_accessible :email, :loginname, :gender, :dob, :timezone, :isdst, :weight_units, :measurement_units,
    :profile_aboutme, :profile_targetweight, :profile_weights, :profile_measurements, :profile_foods, :profile_exercise

  validates_presence_of :loginname, :message => 'You need to enter a login name.'
  validates_format_of :loginname, :with => /\A[a-z0-9\._-]+\Z/i,
    :message => "Please pick a loginname using the following characters only: 'a'-'z', '0'-'9', '.', '_' and '-'."
  validates_uniqueness_of :loginname, :allow_nil => true, :case_sensitive => false,
    :message => 'That login name is already taken. Please select another one.'
  validates_date :dob, :message => 'Please pick a valid date of birth.'
  validates_inclusion_of :gender, :in => %w(m f), :message => 'Please pick a valid gender.'
  validates_inclusion_of :weight_units, :in => %w(lbs kg), :message => 'Please pick a valid weight unit.'
  validates_inclusion_of :measurement_units, :in => %w(inches cm), :message => 'Please pick a valid measurement unit.'
  validates_inclusion_of :timezone, :in => [-720, -660, -600, -540, -480, -420, -360, -300, -240, -210, -180, -120, -60, 0,
  60, 120, 180, 210, 240, 270, 300, 330, 345, 360, 420, 480, 540, 570, 600, 660, 720, 780], :message => 'Please pick a valid time zone.'

  def get_date
    date = Time.now
    date += self[:timezone].to_i.minutes
    date += 1.hour if isdst
    date.to_date
  end

  def get_weights(meth = :all, direction = 'DESC', conditions = nil, limit = nil)
    weights.find(meth, :order => "taken_on #{direction}", :conditions => conditions, :limit => limit)
  end

  def self.admin_pagination(page)
    paginate :page => page, :per_page => 20, :order => 'id ASC'
  end

  protected
    def before_validation
      # make sure the gender is lowercase
      if self[:gender] && !self[:gender].blank?
        self[:gender] = self[:gender].downcase
      else
        self[:gender] = 'm'
      end

      # strip any html tags and sanitize the aboutme text
      self[:profile_aboutme] = self[:profile_aboutme].strip_tags.sanitize if !self [:profile_aboutme].nil?
    end
end
