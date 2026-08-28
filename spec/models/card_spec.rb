# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Card, type: :model do # rubocop:disable Metrics/BlockLength
  subject(:cards) { described_class.all }

  let(:expected_cards) do
    {
      guard: [1, 5, true, false, true],
      priest: [2, 2, true, false, false],
      baron: [3, 2, true, false, false],
      handmaid: [4, 2, false, false, false],
      prince: [5, 2, true, true, false],
      king: [6, 1, true, false, false],
      countess: [7, 1, false, false, false],
      princess: [8, 1, false, false, false]
    }
  end

  it 'defines the eight classic cards with their values, counts, and flags' do
    expect(cards.size).to eq(8)

    expected_cards.each do |key, (value, count, requires_target, can_target_self, requires_guess)|
      card = described_class[key]

      expect(card).to have_attributes(
        key: key,
        name: key.to_s.capitalize,
        value: value,
        count_in_deck: count,
        requires_target?: requires_target,
        can_target_self?: can_target_self,
        requires_guess?: requires_guess
      )
      expect(card.effect).to be_a(String).and be_present
    end
  end

  it 'expands to a sixteen-card deck in the specified quantities' do
    deck = described_class.deck

    expect(deck.size).to eq(16)
    expect(deck.tally.transform_keys(&:key)).to eq(expected_cards.transform_values { |(_, count, *)| count })
  end

  it 'looks cards up by symbol or string key' do
    expect(described_class[:guard]).to be(cards.first)
    expect(described_class['princess']).to be(cards.last)
  end

  it 'compares cards by value' do
    expect(described_class[:guard]).to be < described_class[:priest]
    expect(cards.max).to be(described_class[:princess])
  end

  it 'exposes only frozen catalogue values' do
    expect(cards).to be_frozen
    expect(described_class.deck).to be_frozen
    expect(cards).to all(be_frozen)
  end
end # rubocop:enable Metrics/BlockLength
