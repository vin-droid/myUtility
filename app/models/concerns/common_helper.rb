module CommonHelper
  extend ActiveSupport::Concern


  class ::Integer
    def to_mb
      (self / 1000000.0).round(2)
    end

    def to_kb
      (self / 1000.0).round(2)
    end
  end


  class ::Float
    def to_mb
      (self / 1000000.0).round(2)
    end

    def to_kb
      (self / 1000.0).round(2)
    end
  end


  class ::Array

    # Check wether all emails are valid or not?
    def is_valid_emails?
      extract_valid_emails.size == count
    end

    # Returns valid emails - Return::Type::Array
    def extract_valid_emails
      reject { |e| e.blank? || e.nil? || [nil, 'nil', 'null', 'na'].include?(e.to_s.downcase) }.select { |e| (e.count('@') == 1) && (e =~ /\A\S+@.+\.\S+\z/) }
    end

  end



  class ::String
    def to_dirname
      File.basename(self, ".*").split(" ").join("-")
    end
  end

  def remove_file(filepath)
    File.delete(filepath) if File.exist?(filepath)
  end

  def zip_path(filename)
    "#{Rails.root}/storage/#{filename}.zip"
  end
  def remove_files(dirname)
    FileUtils.rm_rf(dirname) unless Dir[dirname].empty?
  end

  module ClassMethods
    def remove_file(filepath)
      File.delete(filepath) if File.exist?(filepath)
    end
    def zip_path(filename)
      "#{Rails.root}/storage/#{filename}.zip"
    end
    def remove_files(dirname)
      FileUtils.rm_rf(dirname) unless Dir[dirname].empty?
    end
  end
end
