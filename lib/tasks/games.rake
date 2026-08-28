# frozen_string_literal: true

namespace :games do
  desc 'Delete games finished or untouched for more than 24 hours'
  task cleanup: :environment do
    deleted = Game.cleanup_stale!

    puts "Deleted #{deleted} #{'game'.pluralize(deleted)}."
  end
end
