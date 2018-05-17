class ToolController < ApplicationController
    protect_from_forgery

    def excel_splitter
      begin
        # Upload file
        # read file in chunks
        # write those chunks in excel
        data, file = {}, ''
        excel_splitter_params.tap do |esp|
          file = esp[:filename]
          data = {user_email: esp[:user_email],
            filename: esp[:filename].original_filename,
            chunk_size: esp[:chunk_size],
            file_size: esp[:filename].size,
            user_ip: request.remote_ip
          }
        end

        excel_split_req = ExcelSplitRequest.create!(data)

        filesize_in_mb = excel_split_req.file_size.to_i.to_mb

        raise "Files with size more than #{MAX_FILE_SIZE} mb can not be process." if filesize_in_mb > MAX_FILE_SIZE 

        # Save File to local
        LocalFileUploader.new(file).save

        async =  filesize_in_mb > FILE_SIZE_LIMIT_SYNC

        if async
          GenXl.delay.process_file_async(excel_split_req, 20000)
          flash[:success] = "Files has been successfully processed."
          redirect_back(fallback_location: root_path)
        else
          filename = GenXl.process_file_sync(excel_split_req, 200)
          send_file("#{Rails.root}/storage/#{filename}.zip")
        end
      rescue Exception => e
        flash[:error] = e.message
        redirect_back(fallback_location: root_path)
      end

    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :filename, :chunk_size)
    end

end
