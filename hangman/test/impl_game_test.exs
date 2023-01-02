defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "a new game returns a structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("hello")
    assert game.letters == ["h", "e", "l", "l", "o"]
  end

  test "each letter is a character between a-z" do
    game = Game.new_game("hello")
    assert Enum.all?(game.letters, fn letter -> String.match?(letter, ~r/[a-z]/) end)
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("hello")
      game = Map.put(game, :game_state, state)
      {new_game, tally} = Game.make_move(game, "a")
      assert tally.game_state == state
      assert new_game.game_state == game.game_state
    end
  end

  test "a duplicate letter is reported" do
    game = Game.new_game("hello")
    {game, _} = Game.make_move(game, "h")
    {game, _} = Game.make_move(game, "h")
    assert game.game_state == :already_used
  end

  test "we record letters used" do
    game = Game.new_game()
    {game, _} = Game.make_move(game, "x")
    {game, _} = Game.make_move(game, "y")
    {_, tally} = Game.make_move(game, "x")
    assert tally.used == ["x", "y"]
  end

  test "a good guess is recorded" do
    game = Game.new_game("hello")
    {game, _} = Game.make_move(game, "h")
    assert game.game_state == :good_guess
    {game, _} = Game.make_move(game, "e")
    assert game.game_state == :good_guess
  end

  test "a bad guess is recorded" do
    game = Game.new_game("hello")
    {game, _} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
  end

  test "too many bad guesses loses the game" do
    game = Game.new_game("hello")
    {game, _} = Game.make_move(game, "a")
    {game, _} = Game.make_move(game, "b")
    {game, _} = Game.make_move(game, "c")
    {game, _} = Game.make_move(game, "d")
    {game, _} = Game.make_move(game, "f")
    {game, _} = Game.make_move(game, "g")
    {game, _} = Game.make_move(game, "i")
    assert game.game_state == :lost
  end

  # hello
  test "can handle a sequence of moves" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "l", "x"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x"]],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o", "x", "y"]],
      ["h", :won, 4, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o", "x", "y"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    [
      # guess | state     turns  letters                     used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess, 3, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess, 2, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess, 1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["h", :good_guess, 1, ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h"]],
      ["i", :lost, 0, ["h", "e", "l", "l", "o"], ["a", "b", "c", "d", "e", "f", "g", "h", "i"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
