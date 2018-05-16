require 'creek'
require 'spreadsheet'
require 'fileutils'
require 'pry'

class GenXl

  attr_reader :filename, :header_format
  attr_accessor :row_limit
  def initialize(filename = nil)
    @filename = filename || ""
    @row_limit = 1000
    @header_format = Spreadsheet::Format.new( :color => :black, :weight => :bold, :size => 11)
    @creek = Creek::Book.new(filename)
  end

  def first_sheet
    @creek.sheets[0]
  end

  def split_by(rows_limit = 1000)
    serial_number = 0
    rows = first_sheet.rows
    rows_count = rows.count
    new_rows = []
    new_row = []
    index = 0
    @row_limit = rows_limit

    header = rows.first.values
    rows.each do |row|
      if (index != 0)
        new_rows.push(row.values)
        if (index > 1 && (index % @row_limit == 0) || rows_count == (index+1))
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
    sheet1.row(0).default_format = header_format
    rows.map.with_index(1) do |row, index|
      sheet1.insert_row(index, row)
    end
    dir = File.basename(filename, ".*").split(" ").join("-")
    filepath = "split-files/#{dir}/#{dir}-#{row_limit}-#{serial_number}.xls"
    FileUtils::mkdir_p ("split-files/#{dir}") unless File.directory?("split-files/#{dir}")
    excel.write filepath
    excel = nil
    sheet1 = nil
    rows = []
  end

  def self.process_file_sync(filename, chunk_size)
    self.new(filename).split_by(chunk_size)
  end

  def self.process_file_async(filename, chunk_size)
  	puts "================= Processing===="
    self.new(filename).split_by(chunk_size)
    puts "===============Process complete========="
    puts "===============Zipping========="
    dir = File.basename(filename, ".*").split(" ").join("-")
    zip_input_dir = "split-files/#{dir}"
    ZipFileGenerator.new(zip_input_dir, "storage/#{dir}.zip").write
    puts "===============Zipped========="
    puts "===============Mailing========="
    FileMailer.send_email(recipients: ["vineet@metadesignsolutions.co.uk"], subject: "Zipped file", attachments: Hash["merged-file.zip", File.read("#{Rails.root}/storage/#{dir}.zip")]).deliver
    puts "===============Mailed========="
  end
end
