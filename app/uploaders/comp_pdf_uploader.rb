class CompPdfUploader < CarrierWave::Uploader::Base
  # CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+_]/

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "uploads/competitions/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if mounted_as.to_s == 'time_schedule'
      'time_schedule.pdf' if original_filename
    else
      'detail_rule.pdf' if original_filename
    end
  end
end
