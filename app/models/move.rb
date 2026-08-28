# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :game, touch: true
  belongs_to :participant
end
