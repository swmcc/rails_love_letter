# frozen_string_literal: true

namespace :games do
  desc 'Delete finished games and games untouched for more than 24 hours'
  task cleanup: :environment do
    deleted_count = Game.cleanup!.size
    puts "Deleted #{deleted_count} game(s)."
  end
end
