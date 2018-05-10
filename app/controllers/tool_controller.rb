class ToolController < ApplicationController
    protect_from_forgery
    

    def excel_splitter
    	begin
    	excel_split_req = ExcelSplitRequest.create!(excel_splitter_params)
	    rescue
	    end
    end


    private 

    def excel_splitter_params
        binding.pry
        params.require(:excel_splitter).permit(:user_email, files: [])
    end


end
