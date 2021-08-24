module ActiveModel
  module Validations
    class TransitionValidator < ActiveModel::Validator
      def initialize(options)
        super
        @column              = options[:column].to_s
        valid_transitions    = options[:valid_transitions]
        @when_validations    = options[:when_validations]
        @inclusive           = options[:inclusive]
        @allowed_transitions = {}

        build_valid_transition_lookup(valid_transitions)
      end

      def build_valid_transition_lookup(valid_transitions)
        valid_transitions.each do |transition|
          [transition[:from]].flatten.each do |from|
            [transition[:to]].flatten.each do |to|
              requires_validation    = transition[:requires].present?
              requires_when          = transition[:when].present?
              @allowed_transitions[from] ||= []
              next @allowed_transitions[from] << { to => { requires_validation: false } } unless requires_validation

              @allowed_transitions[from] << {
                to => {
                  requires_validation: true,
                  requires_when: requires_when,
                  requires: transition[:requires].map do |key, value|
                    {
                      key => [value].flatten
                    }
                  end
                }
              }
            end
          end
        end
      end

      def validate(record)
        return true if @when_validations && when_condition_unmet?(record)
        return true unless record.persisted?

        changes = record.changes
        return true unless changes.has_key?(@column)

        column_change     = changes[@column]
        original_value    = column_change[0]
        new_value         = column_change[1]
        valid_transitions = @allowed_transitions[original_value]

        if valid_transitions.nil?
          add_inclusion_errors(record, original_value, new_value) if @inclusive
          return true
        end

        transition = valid_transitions.find { |allowed_transition| allowed_transition[new_value] }
        return invalid_transition_error(record, original_value, new_value) unless transition

        requires_validation = transition[new_value][:requires_validation]
        return true unless requires_validation

        requires_validation_requirements = transition[new_value][:requires]
        validate_requires_field(requires_validation_requirements, original_value, new_value, record)
      end

      private

      def add_inclusion_errors(record, original_value, new_value)
        record.errors.add(
          @column.to_sym,
          "#{@column} cannot transition from #{original_value} to #{new_value}."
        )
      end

      def when_condition_unmet?(record)
        met_conditions = @when_validations.map do |attribute, when_values|
                           current_value = record.read_attribute(attribute)
                           [when_values].flatten.include?(current_value)
                         end

        !met_conditions.all?(true)
      end

      def validate_requires_field(all_requires, original_value, new_value, record)
        all_requires.each do |requirement|
          requirement.map do |attribute, allowed_values|
            current_value = record.read_attribute(attribute)
            next if allowed_values.include?(current_value)

            add_requires_error(record, original_value, new_value, attribute, current_value)
          end
        end
      end

      def invalid_transition_error(record, original_value, new_value)
        record.errors.add(
          @column.to_sym,
          "#{@column} cannot transition from #{original_value} to #{new_value}"
        )
      end

      def add_requires_error(record, original_value, new_value, required_column_name, current_required_value)
        record.errors.add(
          @column.to_sym,
          "#{@column} cannot transition from #{original_value} to #{new_value} while #{required_column_name} is #{current_required_value}"
        )
      end

    end
  end
end
