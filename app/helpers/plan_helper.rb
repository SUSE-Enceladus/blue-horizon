# helper for rendering `terraform show` output as a plan
module PlanHelper
  def terraform_plan(show_output)
    return "" if show_output == nil
    @plan = JSON.parse(show_output)
    @resources = find_resources_recursively(@plan.dig("planned_values", "root_module"))
    render(Rails.configuration.x.terraform_plan_view)
  end

  def resource_icon(resource)
    case resource["type"]
    when /security_group/
      icon = "security"
    when /security_rule/
      icon = "network_policy"
    when /subnet$|virtual_network$/
      icon = "network"
    when /public_ip$|network_interface$/
      icon = "ip"
    when /virtual_machine/
      icon = "node"
    when /key/
      icon = "vpn_key"
    when /storage/
      icon = "storage"
    when /resource_group/
      icon = "namespace"
    else
      icon = "abstract"
    end
    icon
  end

  private

  def find_resources_recursively(tf_module)
    resources = {}

    (tf_module.dig("resources") || [])
        .select { |tf_resource| tf_resource["type"] != "null_resource" && tf_resource["mode"] == "managed" } # ignore data and null resources
        .each { |tf_resource| resources[tf_resource["address"]] = tf_resource } # convert the resources array to a hash, allowing lookup by address

    (tf_module.dig("child_modules") || [])
        .each { |tf_child_module| resources = resources.merge(find_resources_recursively(tf_child_module)) }

    resources
  end
end
