module Filter
  module ActiveRecordExtensions
    module Base
      module ClassMethods
        def filter(**attributes)
          Filter::Base.new(relation: self, attributes: attributes)
        end
      end
    end
  end
end

class ActiveRecord::Base
  extend Filter::ActiveRecordExtensions::Base::ClassMethods
end
