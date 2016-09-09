module Filter
  class ApplyFilter
    class NoFilterError < NoMethodError; end
    attr_reader :filter_name, :filter_value, :relation, :model_class

    def initialize(filter_name, filter_value, relation)
      @filter_name = filter_name.to_sym
      @filter_value = filter_value
      @relation = relation
      @model_class = determine_model_class
    end

    def perform
      if filter_missing?
        raise NoFilterError, "#{model_class.model_name} neither responds to nor has a column named `#{filter_name}`."
      elsif column_exists?
        relation.where(filter_name => filter_value)
      elsif filter_accepts_arguments?
        relation.send(filter_name, filter_value)
      elsif apply_filter?
        relation.send(filter_name)
      else
        relation
      end
    end

    protected

    def filter_missing?
      !model_class.respond_to?(filter_name) && !column_exists?
    end

    def column_exists?
      model_class.column_names.include?(filter_name.to_s)
    end

    def filter_accepts_arguments?
      model_class.method(filter_name).arity != 0
    end

    def apply_filter?
      ActiveRecord::Type::Boolean.new.type_cast_from_user(filter_value)
    end

    def determine_model_class
      relation.try(:model) || relation
    end
  end
end
