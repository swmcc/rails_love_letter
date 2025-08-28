# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'generates a code' do
    g = Game.create!
    expect(g.code).to be_present
  end
end
