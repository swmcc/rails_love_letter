# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :game
  validates :name, presence: true
  validates :session_id, presence: true, uniqueness: { scope: :game_id }
end
