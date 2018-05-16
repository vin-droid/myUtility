class LocalFileUploader


attr_reader :file

	def initialize(file = nil)
		@file = file
	end

	def save
		file_path = Rails.root.join('storage', file.original_filename)
		IO.copy_stream(file.path, file_path)
	  return file_path.to_s
	end
	
end