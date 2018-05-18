require 'creek'
require 'spreadsheet'
require 'fileutils'
require 'benchmark'

class GenXl
  include CommonHelper

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

  def split_by(rows_limit)
    Benchmark.bm do |bm|
    serial_number = count = 0
    rows = first_sheet.rows || []
    header = rows.first.values.map(&:humanize)
    rows_count = 0
    new_rows = new_row = []
    rows_limit && @row_limit = rows_limit
  bm.report do
    rows.each_slice(10000) do |group|
      group.reject! { |e| e.empty?}
      next if group.blank?
      group.each do |row|
        if count != 0 && row.present?
          new_rows.push(row.values)
          if new_rows && count > 1 && new_rows.count == rows_limit
            generate_new_excel(new_rows,header,filepath, serial_number)
            serial_number += 1
            new_rows = []
          end
        end
        count += 1
      end
      rows_count += group.count
    end
    generate_new_excel(new_rows,header,filepath, serial_number) unless new_rows.blank?
    rows = new_rows = nil
  end
end
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
    if File.directory?("split-files/#{dirname}")
      remove_file(filepath)
    else
      FileUtils::mkdir_p ("split-files/#{dirname}")
    end
    filepath = "split-files/#{dirname}/#{dirname}-#{row_limit}-#{serial_number}.xls"
    excel.write(filepath) &&  excel = sheet1 = rows =  nil
  end

  def self.process_file_sync(excel_split_req, chunk_size)
    split_and_zip(excel_split_req, chunk_size)
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

  def self.files_to_zip(dirname)
    zip_input_dir = "split-files/#{dirname}"
    raise "File Directory is empty." if Dir[zip_input_dir].empty?
    remove_file zip_path(dirname)
    ZipFileGenerator.new(zip_input_dir, zip_path(dirname)).write
  end

  def self.send_file_to_mail(dirname, usr_email)
  	filepath = zip_path(dirname)
  	raise "Zipped file not found" unless File.exists? filepath
    FileMailer.send_email(recipients: [usr_email], subject: "Zipped file", attachments: Hash["merged-file.zip", File.read(filepath)]).deliver
  end
end
