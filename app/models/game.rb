# frozen_string_literal: true

class Game < ApplicationRecord
  class InvalidTransition < StandardError; end

  STATES = %w[lobby in_round round_over over].freeze
  TRANSITIONS = {
    'lobby' => %w[in_round],
    'in_round' => %w[round_over over],
    'round_over' => %w[in_round over],
    'over' => []
  }.freeze

  has_many :moves, dependent: :destroy
  has_many :participants, dependent: :destroy
  belongs_to :current_participant, class_name: 'Participant', optional: true

  enum :state, STATES.index_by(&:itself), validate: true

  before_validation(on: :create) { self.code ||= SecureRandom.alphanumeric(6).upcase }

  validates :code, uniqueness: true

  def self.cleanup_stale!(cutoff: 24.hours.ago)
    stale = where(updated_at: ...cutoff)
    finished = where.not(finished_at: nil).where(finished_at: ...cutoff)

    stale.or(finished).find_each.sum { |game| game.destroy! ? 1 : 0 }
  end

  def transition_to!(new_state)
    new_state = new_state.to_s
    unless TRANSITIONS.fetch(state).include?(new_state)
      raise InvalidTransition, "cannot move from #{state} to #{new_state}"
    end

    attrs = { state: new_state }
    attrs[:started_at] = Time.current if new_state == 'in_round' && started_at.nil?
    attrs[:finished_at] = Time.current if new_state == 'over'
    update!(**attrs)
  end

  def start! = transition_to!(:in_round)

  def started? = !lobby?
  def finished? = finished_at.present?
  def joinable? = lobby? && participants.count < (max_players || 4)

  def active_participants = participants.active.by_turn_order

  def last_round_winner
    moves.where(action: 'round_end').order(id: :desc).first&.participant
  end
end
