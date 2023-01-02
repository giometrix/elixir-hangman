defmodule Hangman.Impl.Game do
  alias Hangman.Type

  # It is conventional for a module that defines a structure to export a type named t (a lowercase letter T) describing that struct.
  # This means that code using the module can reference the values being passed to and from the module as ModuleName.t

  # could also have been written type t :: %__MODULE__{...}
  @type t :: %Hangman.Impl.Game{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game :: t
  def new_game do
    new_game(Dictionary.random_word())
  end

  @spec new_game(word: String) :: t
  def new_game(word) do
    # _MODULE__  always contains the current module name.  Could also have been  %Hangman.Impl.Game{ ... }
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  @spec make_move(t, String.t()) :: Type.tally()
  def make_move(game, _guess)
      when game.game_state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  # leading underscore means the variable is unused, so here its used to document what the true is for
  defp accept_guess(game, _guess, _already_used = true) do
    # returns a struct identical to game, but with the game_state field updated
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _already_used) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  def score_guess(game, _good_guess = true) do
    # guessed all the letters
    if Enum.all?(game.letters, &MapSet.member?(game.used, &1)) do
      %{game | game_state: :won}
    else
      %{game | game_state: :good_guess}
    end
  end

  def score_guess(game = %{turns_left: 1}, _bad_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  def score_guess(game, _bad_guess) when game.turns_left > 1 do
    %{game | turns_left: game.turns_left - 1, game_state: :bad_guess}
  end

  defp reveal_guessed_letters(game = %{game_state: :lost}) do
    game.letters |> Enum.map(fn letter -> letter end)
  end

  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter ->
      if MapSet.member?(game.used, letter) do
        letter
      else
        "_"
      end
    end)
  end
end
