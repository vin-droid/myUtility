class ToolController < ApplicationController
    protect_from_forgery
    

    def excel_splitter
      begin
        # Upload file
        # read file in chunks
        # write those chunks in excel
        # excel_split_req = ExcelSplitRequest.create!(excel_splitter_params)

        files_size = excel_splitter_params[:excel_files].map(&:size).sum.to_mb

        # raise "Files with size more than #{MAX_FILE_SIZE} mb can not be process." if files_size > MAX_FILE_SIZE 

        files = excel_splitter_params[:excel_files].map do |file|
          LocalFileUploader.new(file).save
        end
        async =  true

        files.each do |filename|
          if async
            puts "====================== Background process========="
            GenXl.delay.process_file_async(filename, 20000)
          else
            GenXl.process_file_sync(filename, 200)
          end
        end

        unless async
          dir = File.basename(files.first, ".*").split(" ").join("-")
          zip_input_dir = "split-files/#{dir}"
          ZipFileGenerator.new(zip_input_dir, "storage/#{dir}.zip").write
        end

      rescue
      end
      flash[:success] = "Files has been successfully processed."
      if async
        redirect_back(fallback_location: root_path)
      else
        send_file("#{Rails.root}/storage/#{dir}.zip")
      end
    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :excel_files => [])
    end

end
