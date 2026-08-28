# frozen_string_literal: true

class Game < ApplicationRecord
  CLEANUP_AGE = 24.hours

  has_many :participants, dependent: :destroy
  has_many :moves, dependent: :destroy

  before_create { self.code ||= SecureRandom.alphanumeric(6).upcase }

  scope :finished, -> { where.not(finished_at: nil) }
  scope :stale, ->(cutoff = CLEANUP_AGE.ago) { where(updated_at: ...cutoff) }
  scope :eligible_for_cleanup, ->(cutoff = CLEANUP_AGE.ago) { finished.or(stale(cutoff)) }

  def started? = started_at.present?
  def start! = update!(started_at: Time.current)
  def finished? = finished_at.present?
  def finish! = update!(finished_at: Time.current)
  def joinable? = !started? && participants.count < (max_players || 4)

  def self.cleanup!(cutoff: CLEANUP_AGE.ago)
    eligible_for_cleanup(cutoff).destroy_all
  end
end
