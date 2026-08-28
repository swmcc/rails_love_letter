# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  has_many :participants, dependent: :destroy

  before_create { self.code ||= SecureRandom.alphanumeric(6).upcase }

  def self.cleanup_stale!(cutoff: 24.hours.ago)
    stale = where(updated_at: ...cutoff)
    finished = where.not(finished_at: nil).where(finished_at: ...cutoff)

    stale.or(finished).find_each.sum { |game| game.destroy! ? 1 : 0 }
  end

  def started? = started_at.present?
  def start! = update!(started_at: Time.current)
  def joinable? = !started? && participants.count < (max_players || 4)
end
