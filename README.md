# Love Letter (Rails Edition)

A multiplayer implementation of the card game [Love Letter](https://en.wikipedia.org/wiki/Love_Letter_(card_game)), built with Rails 8, TailwindCSS, Turbo and RSpec. Players don't need accounts or passwords — enter a name, create or join a game with a shareable code, and play in the browser with live updates.

## Features

- **Full classic rules** – the 16-card deck, all eight card effects, favour tokens and multi-round games.
- **Game lobby** – create games or join by shareable 6-character code (2–4 players).
- **Session-based identity** – players only enter a name; no email or password.
- **Realtime play** – Turbo refresh broadcasts update every connected player's board on each move; broadcasts carry no hand data, so each client only ever renders its own cards.
- **Works without JavaScript** – the card-play forms are plain forms; Stimulus only enhances them.

## The rules as implemented

| Card | Value | Count | Effect |
|---|---|---|---|
| Guard | 1 | 5 | Guess a non-Guard card in another player's hand; they're out if correct |
| Priest | 2 | 2 | Privately look at another player's hand |
| Baron | 3 | 2 | Compare hands; the lower value is out (ties do nothing) |
| Handmaid | 4 | 2 | You cannot be targeted until your next turn |
| Prince | 5 | 2 | Any player (including you) discards their hand and draws — discarding the Princess this way eliminates them |
| King | 6 | 1 | Trade hands with another player |
| Countess | 7 | 1 | Must be played if your other card is the King or a Prince |
| Princess | 8 | 1 | You are out if she leaves your hand for any reason |

- Each round: shuffle, burn one card face down (in 2-player games, three more are removed face up), deal one card each; on your turn you draw and play one of your two cards.
- If every possible target is protected or eliminated, a targeted card may be played with no effect (it is still discarded).
- A round ends when one player remains, or when the deck is empty at the start of a turn — remaining players then compare hands: highest card wins, ties broken by the sum of discarded values, then by earliest turn order (deterministic house tiebreak).
- The round winner gains a favour token and leads the next round. First to **7** tokens (2 players), **5** (3 players) or **4** (4 players) wins the game, then a one-click rematch re-seats everyone.

## Requirements

- Ruby 3.4+
- Rails 8
- PostgreSQL

## Setup

```
bin/rails db:create db:migrate
bin/dev
```

Visit http://localhost:3000 — or use the Makefile: `make setup`, `make run`, and `make help` for everything else.

## Running checks

```
make test        # bundle exec rspec
make lint        # bundle exec rubocop
make security    # bundle exec brakeman
make check       # all of the above
```

CI (GitHub Actions) runs RSpec, RuboCop and Brakeman on every push and pull request.

The test suite covers the engine services (dealing, turns, every card effect, round scoring) plus request- and system-level games: two multi-session end-to-end specs play complete games over HTTP with rigged decks for determinism.

## How it works

- Identity lives in the Rails session (`session[:sid]` + `session[:pname]`); no user records exist.
- Game state is persisted (`Game`, `Participant`, `Move`): the deck and hands are arrays of card keys, every play is recorded as a `Move` with its outcome payload, and the move log renders private reveals (e.g. the Priest) only to the player entitled to see them.
- The engine is a set of small service objects: `StartRound`, `BeginTurn`, `AdvanceTurn`, `PlayCard`, `EndRound` and one `CardEffects::*` resolver per card.
- Realtime updates use Turbo's refresh broadcasts (morphing enabled): any change to a game touches it, which refreshes every subscribed client and the lobby list.
- Old games are cleaned up with `bin/rails games:cleanup` (deletes games finished or untouched for more than 24 hours).

## License

MIT – free to use, modify, and share.
