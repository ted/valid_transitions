require_relative '../test_helper.rb'
module ActiveModel
  module Validations
    class TransitionValidatorTest < ActiveSupport::TestCase

      def test_requires_validation_with_when_met
        expected_errors = {
          :doors =>["doors cannot transition from closed to opened while state is 1st_gear"]
        }
        car = Car.create(state: '1st_gear', doors: 'closed', brand: 'bmw')
        car.update(doors: 'opened')
        assert_equal expected_errors, car.errors.messages
      end

      def test_requires_validation_with_when_unmet
        car = Car.create(state: '1st_gear', doors: 'closed', brand: 'ford')
        car.update(doors: 'opened')
        assert car.valid?
      end

      def test_state_validation_not_allowed_transition
        expected_errors = {
          :state=>["state cannot transition from parked to 2nd_gear"]
        }
        car = Car.create(state: 'parked', doors: 'closed')
        car.update(state: '2nd_gear')
        refute car.valid?
        assert_equal expected_errors, car.errors.messages
      end

      def test_state_validation_up_and_down_allowed_transitions
        car = Car.create(state: 'parked', doors: 'closed')
        car.update!(state: '1st_gear')
        car.update!(state: '2nd_gear')
        car.update!(state: '3rd_gear')
        car.update!(state: '2nd_gear')
        car.update!(state: '1st_gear')
        car.update!(state: 'parked')
        car.update!(state: 'reverse')
      end

      def test_state_validation_up_and_down_allowed_transitions
        car = Car.create(state: 'parked', doors: 'closed')
        car.update!(state: '1st_gear')
        car.update!(state: '2nd_gear')
        car.update!(state: '3rd_gear')
        car.update!(state: '2nd_gear')
        car.update!(state: '1st_gear')
        car.update!(state: 'parked')
        car.update!(state: 'reverse')
      end

      def test_multiple_when_to_one_to
        car = Car.create(state: 'parked', doors: 'closed', condition: 'working')
        car.update!(condition: 'broken')
        car.update!(condition: 'working')
        car.update!(condition: 'requires_service')

      end

    end
  end
end
