# frozen_string_literal: true

# Terraform variable collection built dynamically from variables in a Source
# Supported types: string, number, boolean, list, map.
# Non-string lists, non-string maps, and objects are not supported at this time.

class Variable
  include ActiveModel::Model

  KEY_PREFIX = 'tfvars.'

  def initialize(source_content)
    @plan = HCL::Checker.parse(source_content)['variable'] || {}
    @plan.keys.each do |key|
      self.class.send(:attr_accessor, key)
      instance_variable_set(
        "@#{key}",
        KeyValue.get(storage_key(key), default(key))
      )
    end
  end

  def storage_key(key)
    KEY_PREFIX + key
  end

  def type(key)
    @plan[key]['type'] || 'string'
  end

  def default(key)
    @plan[key]['default'] || case type(key)
    when 'number'
      0
    when 'boolean'
      false
    when 'list'
      []
    when 'map'
      {}
    else
      ''
    end
  end

  def description(key)
    @plan[key]['description']
  end

  def attributes
    Hash[
      @plan.keys.collect do |key|
        [key, instance_variable_get("@#{key}")]
      end
    ] || {}
  end

  def attributes=(hash)
    hash.to_hash.each do |key, value|
      key = key.to_s
      if @plan.keys.include?(key)
        instance_variable_set(
          "@#{key}",
          cast_value_for_key_type(key, value)
        )
      else
        Rails.logger.warn("'#{key}' is not a valid variable name")
      end
    end
  end

  def strong_params
    @plan.keys.collect do |key|
      case type(key)
      when 'list'
        { key => [] }
      when 'map'
        { key => {} }
      else
        key
      end
    end
  end

  def save!
    @plan.keys.each do |key|
      KeyValue.set(storage_key(key), instance_variable_get("@#{key}"))
    end
  end

  def save
    save!
    return true
  rescue ActiveRecord::ActiveRecordError => e
    errors[:base] << e.message
    return false
  end

  private

  def cast_value_for_key_type(key, value)
    case type(key)
    when 'number'
      BigDecimal(value)
    when 'boolean'
      ActiveModel::Type::Boolean.new.cast(value)
    when 'list'
      value.collect(&:to_s)
    when 'map'
      Hash[value.collect { |k, v| [k.to_s, v.to_s] }]
    else
      value.to_s
    end
  end
end
