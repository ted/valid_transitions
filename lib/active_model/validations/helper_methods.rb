require 'active_model/validations'
require 'valid_transitions/input_validator'
module ActiveModel
  module Validations

    module HelperMethods

      def validate_transitions(column, options = {})
        options = options.with_indifferent_access

        ValidTransitions::InputValidator.validate_options(options)

        transitions = options[:transitions]
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
