class ToolController < ApplicationController
    protect_from_forgery
    

    def excel_splitter
      begin
        # Upload file
        # read file in chunks
        # write those chunks in excel
        excel_split_req = ExcelSplitRequest.create!(excel_splitter_params)
        # Parallel.map(excel_split_req.excel_files.map(&:blob), in_threads: 4 ) do |blob|
        #   GenXl.new(blob)
        # end
        binding.pry
        files = excel_splitter_params[:excel_files].map do |file|
          LocalFileUploader.new(file).save
        end

        files.each do |filename|
          GenXl.new(filename).delay.split_by 200
        end
      rescue
      end
      redirect_back(fallback_location: root_path)
    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :excel_files => [])
    end

end
