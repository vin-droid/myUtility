class ToolController < ApplicationController
    protect_from_forgery
    

    def excel_splitter
    	begin
	       binding.pry
         excel_split_req = ExcelSplitRequest.create!(excel_splitter_params )
         ExcelSplitRequest.delay.deliver
      rescue
	    end
    end

    private 
    def excel_splitter_params
      params.require(:excel_splitter).permit(:user_email, :excel_files => [])
    end

end
