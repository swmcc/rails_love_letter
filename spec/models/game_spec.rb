# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end

  it 'requires code to be unique' do
    Game.create!(code: 'ABC123')
    duplicate = Game.new(code: 'ABC123')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:code]).to be_present
  end
end
