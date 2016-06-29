# encoding: utf-8

require 'carrierwave/processing/mime_types'
class Kindeditor::AssetUploader < CarrierWave::Uploader::Base

  EXT_NAMES = {:image => RailsKindeditor.upload_image_ext,
               :flash => RailsKindeditor.upload_flash_ext,
               :media => RailsKindeditor.upload_media_ext,
               :file => RailsKindeditor.upload_file_ext}

  # Include RMagick or ImageScience support:
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  #for user private resource path
  attr_accessor :private_path
  attr_accessor :fixed_folder
  #use this to set the digest filename for a special upload
  attr_accessor :digest_filename


  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}_#{mounted_as}/#{model.id}"
    @store_dir ||= [RailsKindeditor.upload_store_dir].
        push(private_path).
        push(calcuate_object_folder).
        flatten.compact.join("/").gsub(/(kindeditor\/)|(_uploader)/, '')
  end


  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end


  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  # store! nil's the cache_id after it finishes so we need to remember it for deletition
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end

  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
      FileUtils.rm_rf(File.join(cache_dir, @cache_id_was))
    end
  end

  def filename
    "#{cache_id}.#{file.extension}"
  end

  def self.save_upload_info?
    begin
      %w(asset file flash image media).each do |s|
        "Kindeditor::#{s.camelize}".constantize
      end
      return true
    rescue
      return false
    end
  end

  private

  def calcuate_object_folder
    if Kindeditor::AssetUploader.save_upload_info?
      [model.asset_type.to_s.underscore, fixed_folder.nil? ? model.created_at.strftime("%Y%m%d") : fixed_folder]
    else
      [self.class.to_s.underscore, fixed_folder.nil? ? Time.now.strftime("%Y%m%d") : fixed_folder]
    end
  end

end