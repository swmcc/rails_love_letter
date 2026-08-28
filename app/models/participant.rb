# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :game

  validates :name, :session_id, presence: true
  validates :session_id, uniqueness: { scope: :game_id }

  scope :active, -> { where(eliminated: false) }
  scope :by_turn_order, -> { order(:turn_order) }

  def protected? = protected_until_turn?

  def holds?(card_key) = hand.include?(card_key.to_s)

  def eliminate!
    update!(eliminated: true, hand: [], discards: discards + hand)
  end
end
