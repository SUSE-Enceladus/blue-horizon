# frozen_string_literal: true

# Class to wrap all Terraform operations
class Terraform
  def initialize
    config_terraform
    init_terraform
  end

  def init_terraform
    RubyTerraform.init(
      from_module: '', path: Rails.configuration.x.source_export_dir,
      backend: false
    )
  end

  def config_terraform
    logger = Logger.new(
      RubyTerraform::MultiIO.new(STDOUT, log_file),
      level: :debug
    )
    RubyTerraform.configure do |config|
      config.binary = find_default_binary
      config.logger = logger
      config.stdout = logger
      config.stderr = logger
    end
  end

  def log_file
    log_path_filename = Rails.configuration.x.terraform_log_filename
    return Logger::LogDevice.new(log_path_filename)
  end

  def find_default_binary
    return `which terraform`.strip
  end

  def validate(parse_output, file=false)
    validate_params = {
      directory: Rails.configuration.x.source_export_dir
    }
    if parse_output
      RubyTerraform.configuration.stderr = StringIO.new
      validate_params[:no_color] = true
    end
    RubyTerraform.validate(validate_params)
  rescue RubyTerraform::Errors::ExecutionError
    if parse_output
      error_output = RubyTerraform.configuration.stderr.string
      Rails.logger.error error_output
      write_log_output(error_output)
      return parse_error_output(error_output, file)
    end
  ensure
    RubyTerraform.configuration.stderr = RubyTerraform.configuration.logger if
      parse_output
  end

  def write_log_output(content)
    f = File.open(Rails.configuration.x.terraform_log_filename, 'a')
    f.write(content)
    f.flush
  end

  def parse_error_output(message, file=false)
    start = message.index('Error: ')
    start += 'Error: '.length
    limit = message[start, message.length].index("\n")
    parsed_message = message[start, limit]
    line = message =~ /line [0-9]+,/

    parsed_message += add_filename(message) if file
    parsed_message += " in #{message[line, 6]}:"
    suggestion = message.rindex(':') + 1
    parsed_message += message[suggestion, message.length]
    return parsed_message
  end

  def add_filename(error_message)
    export_dir = Rails.configuration.x.source_export_dir.to_s
    export_dir = export_dir[Rails.root.to_s.length + 1, export_dir.length]
    local_dir = error_message.index(export_dir)
    filename = error_message.slice(local_dir, error_message.length)
    boundary = export_dir.length + 1
    filename = filename.slice(boundary, filename.index(' ') - boundary)

    return " on script '#{filename}'"
  end

  def self.statefilename
    Rails.configuration.x.source_export_dir.join('terraform.tfstate')
  end
end
