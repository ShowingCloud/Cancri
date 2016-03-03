class Invite < ApplicationRecord
  belongs_to :team
  belongs_to :user
  belongs_to :user_profile, foreign_key: :user_id
end
