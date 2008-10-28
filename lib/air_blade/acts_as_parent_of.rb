require 'active_support'

module AirBlade
  module ActsAsParentOf

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      # Each child in the array should be the plural form,
      # i.e. matching its has_many declaration.
      def acts_as_parent_of(*children)
        unless included_modules.include? InstanceMethods
          extend ClassMethods
          include InstanceMethods

          children.each do |child|
            self.send :after_update, "save_#{child}"
            self.send :validates_associated, "#{child}"
          end

          children.each do |child|
            singular_child = Inflector.singularize child
            code = <<-END
              def new_#{singular_child}_attributes=(attrs)
                attrs.each do |attributes|
                  #{child}.build attrs
                end
              end

              def existing_#{singular_child}_attributes=(attrs)
                #{child}.reject(&:new_record?).each do |child_model|
                  attributes = attrs[child_model.id.to_s]
                  if attributes
                    child_model.attributes = attributes
                  else
                    #{child}.delete child_model
                  end
                end
              end

              def save_#{child}
                #{child}.each do |child_model|
                  child_model.save(false)
                end
              end
            END
            module_eval code, __FILE__, __LINE__
          end

        end
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end

  end
end
