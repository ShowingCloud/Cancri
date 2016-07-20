class VideoUploader < CarrierWave::Uploader::Base
  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+_]/
  # include CarrierWave::Video
  include CarrierWave::MiniMagick

  # process encode_video: [:mp4, resolution: '640x360']
  # version :mp4 do
  #   def full_filename(for_file)
  #     super.chomp(File.extname(super)) + '.mp4'
  #   end
  # end

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/demeanor_#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(swf flv mp3 mp4 wav wma wmv mid avi mpg asf rm rmvb)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    'video.mp4' if original_filename
  end
end
