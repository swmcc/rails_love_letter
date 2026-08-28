# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :moves, dependent: :destroy

  before_validation :ensure_code, on: :create

  validates :code, presence: true, uniqueness: true

  def started? = started_at.present?
  def start! = update!(started_at: Time.current)
  def joinable? = !started? && participants.count < (max_players || 4)

  private

  def ensure_code
    self.code ||= SecureRandom.alphanumeric(6).upcase
  end
end
