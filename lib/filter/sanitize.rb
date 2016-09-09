module Filter
  class Sanitize
    include ActiveModel::ForbiddenAttributesProtection

    def sanitize(attributes)
      sanitize_for_mass_assignment(attributes)
    end
  end
end
