require 'active_support'

module AirBlade
  module ActsAsParentOf

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods

      # +children+ should be an array of symbols matching the
      # appropriate +has_many+ and +has_one+ associations.
      #
      # For example:
      #
      #   class Project < ActiveRecord::Base
      #     has_many :tasks, :dependent => :destroy
      #     has_one :budget, :dependent => :destroy
      #
      #     acts_as_parent_of :tasks, :budget
      #   end
      #
      def acts_as_parent_of(*children)
        children.each do |child|
          self.send :after_update, "save_#{child}"
          self.send :validates_associated, "#{child}"
        end

        has_manys = children & reflect_on_all_associations(:has_many).map(&:name)
        has_ones = children & reflect_on_all_associations(:has_one).map(&:name)

        has_manys.each do |child|
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

        has_ones.each do |child|
          code = <<-END
            def new_#{child}_attributes=(#{child}_attributes)                          # def new_budget_attributes=(budget_attributes)
              build_#{child} #{child}_attributes                                       #   build_budget budget_attributes
            end                                                                        # end

            # TODO: existing child

            def save_#{child}                                                          # def save_budget
              #{child}.save(false)                                                     #   budget.save(false)
            end                                                                        # end
          END
          module_eval code, __FILE__, __LINE__
        end
      end

    end

  end
end
