class Sponsor < ActiveRecord::Base
  require 'uri'
  has_one :address
  has_many :sponsor_sessions
  has_many :sessions, through: :sponsor_sessions
  has_many :member_contacts
  has_many :contacts, through: :member_contacts, class_name: 'Member', foreign_key: 'member_id'

  validates :name, :address, :avatar, :website, :seats, presence: true
  validate :website_is_url 

  default_scope -> { order('updated_at desc') }

  mount_uploader(:avatar, AvatarUploader) if Rails.env.production?

  accepts_nested_attributes_for :address, :contacts

  def coach_spots
    number_of_coaches || (seats/2.0).round
  end

  def self.latest
    SponsorSession.order("created_at desc").limit(15).map(&:sponsor)
  end

  private

  def website_is_url
    begin
      uri = URI.parse(website)
      valid = uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
    rescue URI::InvalidURIError
      valid = false
    end
    errors.add(:website, "must be a full, valid URL") unless valid
  end
end
