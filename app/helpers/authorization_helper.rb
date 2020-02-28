# frozen_string_literal: true

# Authorize access to steps
module AuthorizationHelper
  def can(path)
    result = case path
    when plan_path
      all_variables_are_set?
    when deploy_path
      plan_exists?
    when download_path
      plan_exists? && apply_log_exists?
    else
      true
    end
    logger.debug "AUTH: #{result ? 'can' : 'cannot'} access #{path}"
    return result
  end

  private

  def all_variables_are_set?
    variables = Variable.load
    variables.attributes.all? do |key, value|
      variables.type(key) == 'bool' ||
        !variables.required?(key) ||
        value.present?
    end
  end

  def export_file_exists?(filename)
    path = Rails.configuration.x.source_export_dir.join(filename)
    File.exist?(path)
  rescue StandardError
    false
  end

  def plan_exists?
    export_file_exists?('current_plan')
  end

  def apply_log_exists?
    export_file_exists?('tf-apply.log')
  end
end
