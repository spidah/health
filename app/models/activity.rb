class Activity < ActiveRecord::Base
  belongs_to :user

  protected
    def after_find
      self[:duration] /= 100 if self[:duration]
      self[:calories] /= 100 if self[:calories]
    end

    def before_save
      self[:duration] *= 100
      self[:calories] *= 100
    end
end
