require 'creek'
require 'spreadsheet'
require 'fileutils'
require 'pry'

class GenXl
	def initialize(filename = nil)
		@filename = filename || ""
		@row_limit = 1000
		@header_format = Spreadsheet::Format.new( :color => :black, :weight => :bold, :size => 11)
		@creek = Creek::Book.new(filename)
	end

	def first_sheet
		@creek.sheets[0]
	end

	def filename
		@filename
	end

	def row_limit
		@row_limit
	end

	def format
		@header_format
	end

	def split_by(row_limit = 1000)
		serial_number = 0
		rows = first_sheet.rows
		rows_count = rows.count
		new_rows = []
		new_row = []
		index = 0
		row_limit && @row_limit = row_limit

		header = rows.first.values
		rows.each do |row|
			puts "=================#{index} row"
			puts "=================#{row.values} row"
			if (index != 0)
				new_rows.push(row.values)

				if (index > 1 && (index % @row_limit == 0) || rows_count == index)
					generate_new_excel(new_rows,header,filename, serial_number)
					serial_number += 1
					new_rows = []
				end
			end
		 	index += 1
		end
		rows = []
	end

	def generate_new_excel(rows = [], header = [], filename, serial_number)
		excel = Spreadsheet::Workbook.new
		sheet1 = excel.create_worksheet
		sheet1.insert_row(0, header)
		sheet1.row(0).default_format = format
		rows.map.with_index(1) do |row, index|
			sheet1.insert_row(index, row)
		end
		dir = File.basename(filename, ".*").split(" ").join("-")
		filepath = "split-files/#{dir}/#{dir}-#{row_limit}-#{serial_number}.xls"
		FileUtils::mkdir_p ("split-files/#{dir}") unless File.directory?("split-files/#{dir}")
		puts "=====writing============#{filepath} "
		excel.write filepath
		excel = nil
		sheet1 = nil
		rows = []
		puts "end"
	end
end