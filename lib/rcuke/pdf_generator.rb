require 'pdfkit'
# Also requires additional libraries to be installed:
# brew install wkhtmltopdf
# or
# gem install wkhtmltopdf-binary

# Create PDF version of whatever file is passed in.
class PdfGenerator
  attr_accessor :pdf_file

  def initialize
    @pdf_file = nil
  end

  def create_pdf(file)
    ignore_pdf = false
    @pdf_file = Tempfile.new(['results', '.pdf'])
    PDFKit.configure do |config|
      # Hack to easily find path to wkhtmltopdf without having to manually specifing path.
      script = "which wkhtmltopdf"
      path = (%x[#{script}]).sub(/\n$/, '')
      if path.nil? || path.empty?
        ignore_pdf = true
        puts "WARNING: could not find path for wkhtmltopdf. Try 'which wkhtmltopdf' in console to ensure you " +
             "have it installed, or try 'brew install wkhtmltopdf' or 'gem install wkhtmltopdf-binary' to install.\n"
      end
      config.wkhtmltopdf = path
      config.default_options[:ignore_load_errors] = true
    end
    if ignore_pdf == false
      kit = PDFKit.new(file.read, :page_size => 'Letter')
      kit.to_file(@pdf_file.path)
    end
    ignore_pdf ? nil : @pdf_file
  end

  def close_pdf
    if @pdf_file
      @pdf_file.close
      @pdf_file.unlink
    end
  end
end