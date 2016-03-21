class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
  GENDER = {male: 1, female: 2}
end
