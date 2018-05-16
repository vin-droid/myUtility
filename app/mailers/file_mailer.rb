class FileMailer < ApplicationMailer
	  include CommonHelper
  default from: 'vineetsahu3493@gmail.com'
  layout 'mailer'



  def send_email(options = {})
    if options.present?
      @options = options
      @to = (options[:recipients] || []).extract_valid_emails
      @cc = (options[:cc] || []).extract_valid_emails
      @bcc = (options[:bcc] || []).extract_valid_emails
      @template = options[:template] || ''
      @subject = options[:subject] || 'Default email from Ecxel Splitter'
      @from = options[:from] || "vineetsahu3493@gmail.com"
      @reply_to = options[:reply_to]

      (@options[:attachments] || {}).each do |attachment_k, attachment_v|
        attachments["#{attachment_k}"] = attachment_v
      end

      mail_hash = {from: @from, to: @to, cc: @cc, bcc: @bcc, subject: @subject, reply_to: @reply_to}

      %w(from reply_to).each do |ignore|
        mail_hash.delete(ignore.to_sym) unless mail_hash[ignore.to_sym].present?
      end

      mail(mail_hash) do |format|
        format.html { render @template } if @template.present?
        format.text { render text: 'Ecxel Splitter' } unless @template.present?
      end
    end
  end

end
