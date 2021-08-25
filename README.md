# ValidTransitions

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/valid_transitions`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valid_transitions'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install valid_transitions

## Usage
`valid_transitions` helps you define ActiveRecord attribute validation to prevent invalid data from going to the database.

As an example, let's say you have this `Car` model:
```ruby
class Car < ActiveRecord::Base
  validates :state,     inclusion: { in: %w[reverse parked 1st_gear 2nd_gear 3rd_gear] }
  validates :doors,     inclusion: { in: %w[opened closed] }
  validates :condition, inclusion: { in: %w[working requires_service broken] }
  validate_transitions :state, transitions: [
                                 { from: %w[reverse],  to: %w[parked 1st_gear]   },
                                 { from: %w[parked],   to: %w[reverse 1st_gear]  },
                                 { from: %w[1st_gear], to: %w[parked 2nd_gear]   },
                                 { from: %w[2nd_gear], to: %w[1st_gear 3rd_gear] },
                                 { from: %w[3rd_gear], to: %w[2nd_gear]          }
                               ]
end
```

When a car is updated from `reverse` to `3rd_gear` using `.update`, the record will fail to persist due to validation.
```ruby
car = Car.create(state: 'reverse', doors: 'closed', brand: 'bmw')
car.update(state: '3rd_gear')
=> false

car.errors.messages
{:state=>["state cannot transition from reverse to 3rd_gear"]}
car.save!
ActiveRecord::RecordInvalid: Validation failed: State state cannot transition from reverse to 3rd_gear
```
- `requires:` allows you to run conditional validation on your state transitions. For an example:
    ```ruby
    class Car < ActiveRecord::Base
      validates :state,     inclusion: { in: %w[reverse parked 1st_gear 2nd_gear 3rd_gear] }
      validates :doors,     inclusion: { in: %w[opened closed] }
      validate_transitions :state, transitions: [
                                     { from: %w[reverse],  to: %w[parked 1st_gear]   },
                                     { from: %w[parked],   to: %w[reverse 1st_gear]  },
                                     { from: %w[1st_gear], to: %w[parked 2nd_gear]   },
                                     { from: %w[2nd_gear], to: %w[1st_gear 3rd_gear] },
                                     { from: %w[3rd_gear], to: %w[2nd_gear]          }
                                   ]

      validate_transitions :doors,
                           transitions: [
                             {
                                from: %w[closed opened],
                                to:   %w[closed opened],
                                requires: { state: 'parked' }
                             }
                           ]
    end
    ```
    `validate_transitions :doors` will fail to persist unless state is `parked`

    ```ruby
    car = Car.create(state: '1st_gear', brand: 'tesla', doors: 'closed')
    car.update(doors: 'opened')
    => false
    car.errors.messages
    => {:doors=>["doors cannot transition from closed to opened while state is 1st_gear"]}
    ```

- `when:` allows you to only run validations when another condition is met. For an example:
    ```ruby
    class Car < ActiveRecord::Base
      validates :state,     inclusion: { in: %w[reverse parked 1st_gear 2nd_gear 3rd_gear]}
      validates :doors,     inclusion: { in: %w[opened closed]}
      validate_transitions :state, transitions: [
                                     { from: %w[reverse],  to: %w[parked 1st_gear]   },
                                     { from: %w[parked],   to: %w[reverse 1st_gear]  },
                                     { from: %w[1st_gear], to: %w[parked 2nd_gear]   },
                                     { from: %w[2nd_gear], to: %w[1st_gear 3rd_gear] },
                                     { from: %w[3rd_gear], to: %w[2nd_gear]          }
                                   ]

      validate_transitions :doors,
                           transitions: [
                             {
                                from: %w[closed opened],
                                to:   %w[closed opened],
                                requires: { state: 'parked' }
                             }
                           ],
                           when: { brand: %w[porsche tesla] }
    end

    ```
    `validate_transitions :doors` will only be executed when brand is `tesla` or `porsche`.

    ```ruby
    car = Car.create(state: '1st_gear', brand: 'toyota', doors: 'closed')
    car.update(doors: 'opened')
    => true
    ```
- `inclusive:` allows you to only allow transitions you've included in the list. By default this is `true`.
    ```ruby
    class Car < ActiveRecord::Base
      #...
      validate_transitions :condition,
                           transitions: [
                             {
                                from: %w[working requires_service],
                                to:   %w[working requires_service broken]
                             }
                           ],
                           inclusive: false
    end

    ```

    By passing `inclusive:` as `false`, updating `condition` from a value that is not included in the list will pass validation.
    ```ruby
    car = Car.create(condition: 'broken', state: '1st_gear', brand: 'toyota', doors: 'closed')
    car.update(condition: 'working')
    => true
    ```

    When inclusive is `true`, the default value, an error will occur:
    ```ruby
    class Car < ActiveRecord::Base
      #...
      validate_transitions :condition,
                           transitions: [
                             {
                                from: %w[working requires_service],
                                to:   %w[working requires_service broken]
                             }
                           ],
                           inclusive: true
    end

    car = Car.create(condition: 'broken', state: '1st_gear', brand: 'toyota', doors: 'closed')
    car.update(condition: 'working')
    => false
    car.errors.messages
    => {:condition=>["condition cannot transition from broken to working."]}
    ```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ValidTransitions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ted/valid_transitions/blob/master/CODE_OF_CONDUCT.md).
