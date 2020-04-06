# Chess

**TODO: Add description**

## Roadmap

- [x] Board
- [x] Movements
  - [x] Pawn
  - [x] Rook
  - [x] King
  - [x] Queen
  - [x] Bishop
  - [x] Knight
- [x] Create game
- [x] Pion's en passant
- [x] Castling
- [ ] Checkmate
- [ ] Checking possible checkmate for next turn
- [ ] Pawn's promotion at last line
- [ ] PGN coordinates on Board Struct


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chess` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess, "~> 0.1.0"}
  ]
end
```


## Using

### Creating a new game

```elixir
Chess.new_game()

%Chess.Game{
  board: %Chess.Board{...},
  pgn: nil
}
```
Stone the game struct, all operations needs this struct

### Quering movements of pieces

```elixir
game = Chess.new_game()

Chess.Game.moves?(game, "a2")

%Chess.Movements.Movement{
  coords: ["a2", "a3", "a4"],
  end: "a4",
  special_move: false,
  start: "a2"
}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chess](https://hexdocs.pm/chess).

