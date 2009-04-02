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
        children.each do |child|
          self.send :after_update, "save_#{child}"
          self.send :validates_associated, "#{child}"
        end

        children.each do |child|
          singular_child = ActiveSupport::Inflector.singularize child
          code = <<-END
            def new_#{singular_child}_attributes=(#{singular_child}_attributes)
              #{singular_child}_attributes.each do |attributes|
                #{child}.build attributes
              end
            end

            def existing_#{singular_child}_attributes=(#{singular_child}_attributes)
              #{child}.reject(&:new_record?).each do |#{singular_child}|
                attributes = #{singular_child}_attributes[#{singular_child}.id.to_s]
                if attributes
                  #{singular_child}.attributes = attributes
                else
                  #{child}.delete #{singular_child}
                end
              end
            end

            def save_#{child}
              #{child}.each do |#{singular_child}|
                #{singular_child}.save(false)
              end
            end
          END
          module_eval code, __FILE__, __LINE__
        end
      end

    end

  end
end
