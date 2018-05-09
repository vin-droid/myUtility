class ToolController < ApplicationController
    protect_from_forgery
    

    def excel_splitter
        excel_splitter_params
    end


    private 

    def excel_splitter_params
        binding.pry
    end


end
