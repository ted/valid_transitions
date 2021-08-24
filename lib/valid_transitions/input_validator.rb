require 'valid_transitions/invalid_input_error'

module ValidTransitions
  module InputValidator
    extend self

    def validate_options(options)
      transitions = options[:transitions]
      validate_transition_type_and_presence(transitions)
      validate_transition_content(transitions)
    end

    private

    def validate_transition_type_and_presence(transitions)
      raise_error("validates_with called without :transitions")                                         unless transitions
      raise_error("validates_with called with :transitions as an #{transitions.class}, expected Array") unless transitions.is_a?(Array)
    end

    def validate_transition_content(transitions)
      transitions.each do |transition|
        raise_error("transition #{transition} missing key :to") unless transition.has_key?('to')
        raise_error("transition #{transition} missing key :from") unless transition.has_key?('from')
      end
    end

    def validate_when(options)
      return true unless options[:when]
      return true if options[:when].is_a?(Hash)

      raise_error("when is #{options[:when]}, which should be a hash")
    end

    def raise_error(message)
      raise ValidTransitions::InvalidInputError, message
    end
  end
end
