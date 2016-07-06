class FileUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}_#{mounted_as}"
  end

  def extension_white_list
    %w(doc docx xls xlsx ppt htm html txt zip rar gz bz2)
  end

  def filename
    "#{cache_id}.#{file.extension}" if original_filename
  end

end