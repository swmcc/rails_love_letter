class Game < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :moves, dependent: :destroy

  before_create { self.code ||= SecureRandom.alphanumeric(6).upcase }

  def started? = started_at.present?
  def start! = update!(started_at: Time.current)
  def joinable? = !started? && participants.count < (max_players || 4)
end
