# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :game

  validates :name, :session_id, presence: true
  validates :session_id, uniqueness: { scope: :game_id }
end
