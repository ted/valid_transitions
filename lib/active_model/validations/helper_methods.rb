require 'active_model/validations'

module ActiveModel
  module Validations

    module HelperMethods

      def validate_transitions(column, options = {})
        transitions = options[:transitions] || [] # Todo
        only_when   = options[:when]
        inclusive   = if options[:inclusive] == false
                        false
                      else
                        true
                      end

        validates_with ActiveModel::Validations::TransitionValidator, {
          column:            column,
          valid_transitions: transitions,
          when_validations:  only_when,
          inclusive:         inclusive
        }
      end
    end

  end
end
