require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'

class RecursiveOpenStruct < OpenStruct
  include DebugInspect

  def initialize(hash=nil, args={})
    @recurse_over_arrays = args.fetch(:recurse_over_arrays, false)
    mutate_input_hash = args.fetch(:mutate_input_hash, false)

    unless mutate_input_hash
      hash = DeepDup.new(recurse_over_arrays: @recurse_over_arrays).call(hash)
    end

    super(hash)

    @sub_elements = {}
  end

  def to_h
    @table.dup.update(@sub_elements) do |k, oldval, newval|
      if newval.kind_of?(self.class)
        newval.to_h
      elsif newval.kind_of?(Array)
        newval.map { |a| a.kind_of?(self.class) ? a.to_h : a }
      else
        raise "Cached value of unsupported type: #{newval.inspect}"
      end
    end
  end

  alias_method :to_hash, :to_h

  def [](name)
    send name
  end

  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) do
          v = @table[name]
          if v.is_a?(Hash)
            @sub_elements[name] ||= self.class.new(v,
                                      :recurse_over_arrays => @recurse_over_arrays,
                                      :mutate_input_hash => true)
          elsif v.is_a?(Array) and @recurse_over_arrays
            @sub_elements[name] ||= recurse_over_array v
          else
            v
          end
        end
        define_method("#{name}=") { |x| modifiable[name] = x }
        define_method("#{name}_as_a_hash") { @table[name] }
      end
    end
    name
  end

  def recurse_over_array array
    array.map do |a|
      if a.is_a? Hash
        self.class.new(a, :recurse_over_arrays => true, :mutate_input_hash => true)
      elsif a.is_a? Array
        recurse_over_array a
      else
        a
      end
    end
  end
end

