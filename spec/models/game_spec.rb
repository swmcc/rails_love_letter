# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end

  it 'requires a unique code' do
    described_class.create!(code: 'ABC123')

    duplicate = described_class.new(code: 'ABC123')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:code]).to include('has already been taken')
  end
end
