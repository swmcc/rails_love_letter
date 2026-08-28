# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Playing a turn', type: :system do
  before { driven_by(:rack_test) }

  it 'walks two players from lobby to a won round' do
    game = nil

    Capybara.using_session(:alice) do
      visit root_path
      fill_in 'name', with: 'Alice'
      click_button 'Continue'
      click_button 'Create Game'
      game = Game.order(:id).last
      expect(page).to have_content(game.code)
    end

    Capybara.using_session(:bob) do
      visit root_path
      fill_in 'name', with: 'Bob'
      click_button 'Continue'
      visit game_path(game)
      click_button 'Join Game'
      expect(page).to have_content('Waiting for Alice to start')
    end

    Capybara.using_session(:alice) do
      visit game_path(game)
      click_button 'Start Game'
      expect(page).to have_content('Game started.')
    end

    # Rig a deterministic position: Alice to play Guard against Bob's Priest.
    alice = game.participants.find_by(name: 'Alice')
    bob = game.participants.find_by(name: 'Bob')
    alice.update!(hand: %w[guard handmaid])
    bob.update!(hand: %w[priest])
    game.reload.update!(current_participant: alice, deck: %w[baron king])

    Capybara.using_session(:alice) do
      visit game_path(game)
      expect(page).to have_content("It's your turn")

      within('form', text: 'Guard') do
        select 'Bob', from: 'target_id'
        select 'Priest (2)', from: 'guess'
        click_button 'Play'
      end

      expect(page).to have_content('hit! They are out.')
      expect(page).to have_content('You won the round')
    end

    Capybara.using_session(:bob) do
      visit game_path(game)
      expect(page).to have_content('Alice')
      expect(page).to have_content('won the round').or have_content('Waiting for Alice')
    end
  end
end
