class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
end
