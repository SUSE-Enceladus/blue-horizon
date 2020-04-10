# frozen_string_literal: true

# Authorize access to steps
module AuthorizationHelper
  def can(path)
    result =
      session_check(path) &&
      flow_restriction_checks(path)
    logger.debug "AUTH: #{result ? 'can' : 'cannot'} access #{path}"
    return result
  end

  def active_session?
    session_id = session[:session_id]
    active_session_id = KeyValue.get(:active_session_id)

    # first request - allowed
    return true if !active_session_id && !session_id

    if !active_session_id && session_id
      # 2nd request - lock it down
      set_session!
      return true
    else
      session_id == active_session_id
    end
  end

  def set_session!
    KeyValue.set(:active_session_id, session[:session_id])
    KeyValue.set(:active_session_ip, request.remote_ip)
  end

  private

  def session_check(path)
    case path
    when welcome_path, reset_session_path
      true
    else
      active_session?
    end
  end

  def flow_restriction_checks(path)
    case path
    when plan_path
      all_variables_are_set?
    when deploy_path
      plan_exists?
    when wrapup_path, download_path
      plan_exists? && apply_log_exists?
    else
      true
    end
  end

  def all_variables_are_set?
    variables = Variable.load

    return false if variables.is_a?(Hash) && variables[:error]

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
    export_file_exists? Terraform.statefilename
  end
end
