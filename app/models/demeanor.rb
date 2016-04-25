class Demeanor < ApplicationRecord
  belongs_to :competition
  validates :competition_id, presence: true
  validates :file_type, presence: true
  mount_uploader :desc, DemeanorUploader


  def to_jq_upload
    {
        "name" => read_attribute(:name),
        "size" => name.size,
        "url" => name.url,
        "thumbnail_url" => name.url,
        "delete_url" => demeanor_path(:id => id),
        "delete_type" => "DELETE"
    }
  end
end

