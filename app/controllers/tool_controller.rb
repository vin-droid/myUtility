class ToolController < ApplicationController
    protect_from_forgery

    def excel_splitter
      begin
        # Upload file
        # read file in chunks
        # write those chunks in excel
        binding.pry
        data = {}
        excel_splitter_params.tap do |esp|
          data = {user_email: esp[:user_email],
            filename: esp[:filename].original_filename,
            chunk_size: esp[:chunk_size],
            file_size: esp[:filename].size,
            user_ip: ""
          }
        end

        excel_split_req = ExcelSplitRequest.create!(data)

        file = excel_splitter_params[:excel_file]

        filesize_in_mb = file.size.to_mb

        # raise "Files with size more than #{MAX_FILE_SIZE} mb can not be process." if files_size > MAX_FILE_SIZE 

        filepath = LocalFileUploader.new(file).save

        async =  true

        if async
          puts "====================== Background process========="
          GenXl.delay.process_file_async(filepath, 20000)
          flash[:success] = "Files has been successfully processed."
          redirect_back(fallback_location: root_path)
        else
          GenXl.process_file_sync(filepath, 200)
          dir = File.basename(files.first, ".*").split(" ").join("-")
          zip_input_dir = "split-files/#{dir}"
          ZipFileGenerator.new(zip_input_dir, "storage/#{dir}.zip").write
          send_file("#{Rails.root}/storage/#{dir}.zip")
        end

      rescue
      end

    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :filename, :chunk_size)
    end

end
