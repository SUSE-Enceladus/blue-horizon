# Terraform variable collection built dynamically from variables in a Source
# Supported types: string, number, boolean, list, map.
# Non-string lists, non-string maps, and objects are not supported at this time.

class Variable
  include ActiveModel::Model

  KEY_PREFIX = 'tfvars.'

  def initialize(source_content)
    @plan = HCL::Checker.parse(source_content)['variable'] || {}
    @plan.collect do |key, options|
      self.class.send(:attr_accessor, key)
      instance_variable_set("@#{key}", KeyValue.get(storage_key(key), default(key)))
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
    when 'string'
      ''
    when 'number'
      0
    when 'boolean'
      false
    when 'list'
      []
    when 'map'
      {}
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
        value = case self.type(key)
        when 'number'
          if value.to_i.to_s == value
            value.to_i
          else
            value.to_f
          end
        when 'boolean'
          ActiveModel::Type::Boolean.new.cast(value)
        when 'string'
          value.to_s
        when 'list'
          value.collect { |v| v.to_s }
        when 'map'
          Hash[value.collect { |k, v| [k.to_s, v.to_s] }]
        end
        instance_variable_set("@#{key}", value)
      else
        Rails.logger.warn("'#{key}' is not a valid variable name")
      end
    end
  end

  def strong_params
    @plan.keys.collect do |key|
      case self.type(key)
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
    self.save!
    return true
  rescue ActiveRecord::ActiveRecordError => e
    errors[:base] << e.message
    return false
  end
end
