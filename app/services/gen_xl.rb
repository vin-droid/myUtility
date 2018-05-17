require 'creek'
require 'spreadsheet'
require 'fileutils'
require 'pry'

class GenXl

  attr_reader :filepath, :header_format
  attr_accessor :row_limit
  def initialize(filepath = nil)
    @filepath = filepath || ""
    @row_limit = 1000
    @header_format = Spreadsheet::Format.new( :color => :black, :weight => :bold, :size => 11)
    @creek = Creek::Book.new(filepath)
  end

  def first_sheet
    @creek.sheets[0]
  end

  def split_by(rows_limit = 1000)
    serial_number = count = 0
    rows = first_sheet.rows || []
    header = rows.first.values.map(&:humanize)
    rows_count = 0
    new_rows = new_row = []
    rows_limit && @row_limit = rows_limit

binding.pry
    rows.each_slice(500).with_index do |group, index|
      puts "=====before #{group.count}"
      group = group.reject { |e| e.empty?}
      next if group.blank?
      p group.count
      rows_count += group.count
      group.each do |row|
        if (count != 0 && row.present?)
          new_rows.push(row.values)
          if (new_rows && count > 1 && ((new_rows.count == rows_limit) || rows_count == (count+1)))
            puts "=========== row size #{new_rows.count}"
            generate_new_excel(new_rows,header,filepath, serial_number)
            serial_number += 1
            new_rows = []
          end
        end
        count += 1
      end
    end
    rows = []
  end

  def generate_new_excel(rows = [], header = [], filepath, serial_number)
    excel = Spreadsheet::Workbook.new
    sheet1 = excel.create_worksheet
    sheet1.insert_row(0, header)
    sheet1.row(0).default_format = header_format
    rows.map.with_index(1) do |row, index|
      sheet1.insert_row(index, row)
    end
    dirname = filepath.to_dirname
    filepath = "split-files/#{dirname}/#{dirname}-#{row_limit}-#{serial_number}.xls"
    FileUtils::mkdir_p ("split-files/#{dirname}") unless File.directory?("split-files/#{dirname}")
    excel.write(filepath) &&  excel = sheet1 = rows =  nil
  end

  def self.process_file_sync(excel_split_req, chunk_size)
    dirname = split_and_zip(excel_split_req, chunk_size)
    ZipFileGenerator.new(zip_input_dir, "storage/#{dirname}.zip").write
    dirname
  end

  def self.process_file_async(excel_split_req, chunk_size)
    dirname = split_and_zip(excel_split_req, chunk_size)
    send_file_to_mail(dirname, excel_split_req.user_email)
  end

  def self.split_and_zip(excel_split_req, chunk_size)
    self.new("#{Rails.root}/storage/#{excel_split_req.filename}").split_by(chunk_size)
    dirname = excel_split_req.filename.to_dirname
    files_to_zip(dirname)
    dirname
  end

  def files_to_zip(dirname)
    zip_input_dir = "split-files/#{dirname}"
    raise "File Directory is empty." if Dir[zip_input_dir].empty?
    ZipFileGenerator.new(zip_input_dir, "storage/#{dirname}.zip").write
  end

  def send_file_to_mail(dirname, usr_email)
  	filepath = "#{Rails.root}/storage/#{dirname}.zip"
  	raise "Zipped file not found" unless File.exits? filepath
    FileMailer.send_email(recipients: usr_email, subject: "Zipped file", attachments: Hash["merged-file.zip", File.read("")]).deliver
  end
end
