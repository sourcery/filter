require 'active_model'

module Filter
  class Base < SimpleDelegator
    attr_reader :original_relation, :relation, :attributes
    include ActiveModel::Model

    DEFAULTS = {}

    delegate :count, to: :relation

    def initialize(attributes: {}, relation: nil)
      @original_relation = relation || default_relation
      setup_ostruct(attributes)
      perform_filtering
    end

    def fork(attributes: {}, skip: [])
      skip = Array.wrap(skip)
      attributes = to_h.merge(attributes)
      attributes.delete_if { |k, v| skip.include?(k) }
      self.class.new(attributes: attributes, relation: original_relation)
    end

    def next(current_record)
      advance(current_record, 1)
    end

    def previous(current_record)
      advance(current_record, -1)
    end

    def advance(record, advancement)
      advanced_id = ids[(index(record) + advancement) % ids.count]
      relation.find(advanced_id)
    end

    def index(record)
      ids.index(record.id)
    end

    def ids
      @ids ||= relation.pluck(:id).uniq
    end

    def to_url(path = nil)
      path ||= ''
      "#{path}?"+to_query
    end

    def to_query
      { filter_base: to_h }.to_query
    end

    def inspect
      super.gsub('OpenStruct', "Filter (#{original_relation.to_s})")
    end

    protected

    def setup_ostruct(attributes)
      defaults = self.class::DEFAULTS
      sanitized_attributes = ::Filter::Sanitize.new.sanitize(attributes)
      attributes_with_defaults = defaults.merge(sanitized_attributes)
      ostruct = OpenStruct.new(attributes_with_defaults)
      __setobj__(ostruct)
    end

    def perform_filtering
      attributes = to_h.delete_if { |k, v| v.nil? || v == '' }

      @relation = attributes.inject(original_relation) do |relation, (filter_name, filter_value)|
        ::Filter::ApplyFilter.new(filter_name, filter_value, relation).perform
      end
    end

    def default_relation
      raise NotImplementedError
    end
  end
end
