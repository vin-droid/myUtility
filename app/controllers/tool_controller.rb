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
        excel_split_req.excel_files.map(&:blob).find_each(batch_size: 1) do |blob|
          gen_xl = GenXl.new(blob)
          gen_xl.split_by(100)
        end



        # Parallel.map(['a','b','c'], in_threads: 3) { |task|}
        # ExcelSplitService.new(excel_splitter_params)
      rescue
      end
      redirect_back(fallback_location: root_path)
    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :excel_files => [])
    end

end
