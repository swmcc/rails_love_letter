# Love Letter (Rails Edition)

A lightweight multiplayer implementation of the card game Love Letter, built with Rails 8, TailwindCSS, Turbo, and RSpec. Players don’t need accounts or passwords — you simply enter your name to join a session, hop into the lobby, and either create or join a game. Once a game has started, no new players may join.

## Features
- Game Lobby – create or join games with a shareable code.
- Session-based identity – players only enter a name, no email or password.
- Turbo + Tailwind – reactive UI with minimal JavaScript.
- RSpec – model and request tests included.

## Requirements
- Ruby 3.4+
- Rails 8
- PostgreSQL

## Setup

Set up the database:
bin/rails db:create db:migrate

Run the development server:
bin/dev

Visit http://localhost:3000

## How It Works
1. Enter Name – When you visit the app, you’re asked for a name.
2. Lobby – You’ll see a list of active games and can create a new one.
3. Join Game – Players can join until the game is started (2–4 players).
4. Start Game – The host starts the round.
5. Play – Players draw and play cards; rounds continue until someone wins.

## Running Tests
bin/rspec

RSpec covers models and request flows (sessions, games, joining, etc.).

## Development Notes
- Identity is stored in the Rails session (session[:sid] + session[:pname]). No permanent user records exist.
- Game state (Game, Participant, Move) is persisted in the database so Turbo Streams can broadcast updates.
- Old games can be cleaned up periodically with a background job or rake task.

## Roadmap
- Implement full Love Letter card rules (Guard, Priest, Baron, etc.).
- Add Turbo Streams for real-time play across browsers.
- Animated card UI with Stimulus + Tailwind transitions.

## License
MIT – free to use, modify, and share.
