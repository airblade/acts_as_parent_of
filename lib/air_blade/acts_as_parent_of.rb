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
            def new_#{singular_child}_attributes=(#{singular_child}_attributes)        # def new_task_attributes=(task_attributes)
              #{singular_child}_attributes.each do |attributes|                        #   task_attributes.each do |attributes|
                #{child}.build attributes                                              #     tasks.build attributes
              end                                                                      #   end
            end                                                                        # end

            def existing_#{singular_child}_attributes=(#{singular_child}_attributes)   # def existing_task_attributes=(task_attributes)
              #{child}.reject(&:new_record?).each do |#{singular_child}|               #   tasks.reject(&:new_record?).each do |task|
                attributes = #{singular_child}_attributes[#{singular_child}.id.to_s]   #     attributes = task_attributes[task.id.to_s]
                if attributes                                                          #     if attributes
                  #{singular_child}.attributes = attributes                            #       task.attributes = attributes
                else                                                                   #     else
                  #{child}.delete #{singular_child}                                    #       tasks.delete task
                end                                                                    #     end
              end                                                                      #   end
            end                                                                        # end

            def save_#{child}                                                          # def save_tasks
              #{child}.each do |#{singular_child}|                                     #   tasks.each do |task|
                #{singular_child}.save(false)                                          #     task.save(false)
              end                                                                      #   end
            end                                                                        # end
          END
          module_eval code, __FILE__, __LINE__
        end
      end

    end

  end
end
