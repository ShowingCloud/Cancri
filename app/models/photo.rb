class Photo < ApplicationRecord
  belongs_to :competition, foreign_key: :type_id
  belongs_to :activity, foreign_key: :type_id
  validates :photo_type, presence: true, inclusion: {in: [0, 1]}
  validates :type_id, presence: true
  mount_uploader :image, CoverUploader


  # def to_jq_upload
  #   {
  #       "name" => read_attribute(:name),
  #       "size" => name.size,
  #       "url" => name.url,
  #       "thumbnail_url" => name.url,
  #       "delete_url" => demeanor_path(:id => id),
  #       "delete_type" => "DELETE"
  #   }
  # end
end

