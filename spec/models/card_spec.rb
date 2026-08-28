# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Card, type: :model do
  describe '.all' do
    it 'returns the eight classic Love Letter cards' do
      expect(described_class.all.map(&:key)).to eq(%i[
        guard
        priest
        baron
        handmaid
        prince
        king
        countess
        princess
      ])
    end

    it 'is frozen with frozen card definitions' do
      expect(described_class.all).to be_frozen
      expect(described_class.all).to all(be_frozen)
    end
  end

  describe '.deck' do
    it 'expands to the sixteen-card classic deck' do
      expect(described_class.deck.size).to eq(16)
      expect(described_class.deck.tally.transform_keys(&:key)).to eq(
        guard: 5,
        priest: 2,
        baron: 2,
        handmaid: 2,
        prince: 2,
        king: 1,
        countess: 1,
        princess: 1
      )
    end
  end

  describe '.[]' do
    it 'looks up cards by symbol or string key' do
      expect(described_class[:guard].name).to eq('Guard')
      expect(described_class['princess'].value).to eq(8)
    end
  end

  it 'compares cards by value' do
    expect(described_class[:guard]).to be < described_class[:priest]
    expect(described_class[:princess]).to be > described_class[:countess]
    expect([described_class[:king], described_class[:baron], described_class[:guard]].sort.map(&:key)).to eq(%i[guard baron king])
  end

  it 'defines values and counts' do
    expect(described_class.all.to_h { |card| [card.key, [card.value, card.count_in_deck]] }).to eq(
      guard: [1, 5],
      priest: [2, 2],
      baron: [3, 2],
      handmaid: [4, 2],
      prince: [5, 2],
      king: [6, 1],
      countess: [7, 1],
      princess: [8, 1]
    )
  end

  it 'defines targeting and guess flags' do
    expect(described_class.all.to_h { |card| [card.key, [card.requires_target?, card.can_target_self?, card.requires_guess?]] }).to eq(
      guard: [true, false, true],
      priest: [true, false, false],
      baron: [true, false, false],
      handmaid: [false, false, false],
      prince: [true, true, false],
      king: [true, false, false],
      countess: [false, false, false],
      princess: [false, false, false]
    )
  end
end
