# frozen_string_literal: true

# Set the kubernetes version to the max available in the selected framework
class K8sVersion
  include ActiveModel::Model
  include KeyPrefixable
  include Saveable
  extend KeyPrefixable

  require 'open3'

  attr_accessor :cloud_framework, :value, :location

  def initialize(*args)
    super
    credentials = case @cloud_framework
      when 'aws'
        {
          access_key_id:     prefixed_get(:access_key_id),
          secret_access_key: prefixed_get(:secret_access_key)
        }
      when 'azure'
        {
          client_id:       prefixed_get(:client_id),
          client_secret:   prefixed_get(:client_secret),
          tenant_id:       prefixed_get(:tenant_id),
          subscription_id: prefixed_get(:subscription_id)
        }
      else
        {}
      end
    @value ||= get_framework_k8s_version(credentials)
  end

  def self.load
    new(
      cloud_framework: Rails.configuration.x.cloud_framework,
      value:           prefixed_get(:k8s_version),
      location:        prefixed_get(:location)
    )
  end

  def self.variable_handlers
    [
      'k8s_version'
    ]
  end

  def get_aws_k8s_api_version(
    access_key_id:, secret_access_key:
  )
    cmd = "get-framework-k8s-api-version ec2 "\
      "--aws-access-key-id #{access_key_id} "\
      "--aws-secret-access-key #{secret_access_key} "\
      "--region-name #{@location}"
    run(cmd)
  end

  def get_azure_k8s_api_version(
    client_id:, client_secret:, tenant_id:, subscription_id:
  )
    cmd = "get-framework-k8s-api-version az "\
      "--client-id #{client_id} "\
      "--client-secret #{client_secret} "\
      "--tenant-id #{tenant_id} "\
      "--subscription-id #{subscription_id} "\
      "--location #{@location}"
    run(cmd)
  end

  def get_gcp_k8s_api_version(*args)
    'latest'
  end

  def run(cmd)
    Rails.logger.debug("Running:\n#{cmd}")
    stdout, stderr, status = Open3.capture3(cmd)
    return stdout
  end

  def get_framework_k8s_version(credentials = {})
    send("get_#{@cloud_framework}_k8s_api_version", credentials)
  end

  def save!
    prefixed_set(:k8s_version, @value)
  end
end
