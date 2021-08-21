class Car < ActiveRecord::Base
  validates :state, inclusion: { in: %w[reverse parked 1st_gear 2nd_gear 3rd_gear]}
  validates :doors, inclusion: { in: %w[opened closed]}
  validates :condition, inclusion: { in: %w[working requires_service broken]}
  validate_transitions :state, transitions: [
                                 { from: %w[reverse], to: %w[1st_gear] },
                                 { from: %w[parked],  to: %w[reverse 1st_gear] },
                                 { from: %[1st_gear], to: %w[parked 2nd_gear] },
                                 { from: %[2nd_gear], to: %w[1st_gear 3rd_gear] },
                                 { from: %[3rd_gear], to: %w[2nd_gear] }
                               ]

  validate_transitions :doors,
                       transitions: [
                         { from: 'closed', to: 'opened', requires: { state: 'parked' } }
                       ],
                       when: { brand: %w[bmw tesla] }

  validate_transitions :condition,
                       transitions: [
                         { from: %w[working requires_service broken], to: %w[working requires_service broken] },
                         # { from: 'broken', to: 'working'}, # TODO: Add logic for when this isnt here
                         # { from: 'working', to: 'requires_service'} # TODO: Add logic for when this isnt here
                       ]


end
