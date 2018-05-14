class ExcelSplitRequest < ApplicationRecord

	has_many_attached :excel_files 


	def deliver
		puts "===============file has been recieved"
	end
end
