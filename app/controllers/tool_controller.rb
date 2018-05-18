class ToolController < ApplicationController
    protect_from_forgery

    def excel_splitter
      begin
        data, file = {}, ''
        excel_splitter_params.tap do |esp|
          file = esp[:filename]
          raise "Please upload a valid file type." unless esp[:filename].content_type.eql? FILE_FORMAT
          data = {user_email: esp[:user_email],
            filename: esp[:filename].original_filename,
            chunk_size: esp[:chunk_size].to_i,
            file_size: esp[:filename].size,
            user_ip: request.remote_ip
          }
        end
        raise "Files with size more than #{MAX_FILE_SIZE} mb can not be process." if filesize_in_mb > MAX_FILE_SIZE 

        excel_split_req = ExcelSplitRequest.create!(data)

        filesize_in_mb = excel_split_req.file_size.to_i.to_mb


        # Save File to local
        LocalFileUploader.new(file).save

        async = filesize_in_mb > FILE_SIZE_LIMIT_SYNC

        if async
          GenXl.delay.process_file_async(excel_split_req, excel_split_req.chunk_size)
          flash[:success] = "Files has been successfully processed."
          redirect_back(fallback_location: root_path)
        else
          filename = GenXl.process_file_sync(excel_split_req, excel_split_req.chunk_size)
          send_file(zip_path(filename))
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
