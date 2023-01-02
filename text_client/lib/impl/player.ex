defmodule TextClient.Impl.Player do

  @typep game :: Hangman.game
  @typep tally :: Hangman.tally
  @typep state :: { game, tally }

  @spec start(game) :: :ok
  def start(game) do
    tally = Hangman.tally(game)
    interact({ game, tally})
  end

  # @type state  :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  @spec interact(state) :: :ok
  def interact({_game, _tally = %{ game_state: :won }}) do
    IO.puts("You won!")
  end

  def interact({_game, tally = %{ game_state: :lost }}) do
    IO.puts("You lost! ... the word was #{tally.letters |> Enum.join}")
  end


  def interact({game, tally}) do
    # feedback
    IO.puts feedback_for(tally)
    # display current word
    IO.puts current_word(tally)
    # make move
    tally = Hangman.make_move(game, get_guess())
    interact( {game, tally} )


  end

  defp feedback_for(tally = %{ game_state: :initializing }), do: "Welcome to Hangman!  I'm thinking of a #{length(tally.letters)} letter word."

  defp feedback_for(tally = %{ game_state: :good_guess }), do: "Good guess!"
  defp feedback_for(tally = %{ game_state: :bad_guess }), do: "Bad guess!"
  defp feedback_for(tally = %{ game_state: :already_used }), do: "You already used that letter!"


  defp current_word(tally) do
    [
      "Word so far: ",
      tally.letters |> Enum.join(" "),
      "   turns left: ",
      tally.turns_left |> to_string,
      "   letters used: ",
      tally.used |> Enum.join(",")
    ]
  end

  defp get_guess do
    IO.gets("Guess a letter: ")
    |> String.trim
    |> String.downcase
  end
end
