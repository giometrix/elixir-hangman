defmodule B1Web.HangmanView do
  use B1Web, :view

  @status_fields %{
    initializing: {"initializing", "Guess a letter"},
    good_guess: {"good_guess", "Good guess!"},
    bad_guess: {"bad_guess", "Bad guess!"},
    won: {"won", "You won!"},
    lost: {"lost", "You lost!"},
    already_used: {"already_used", "You already used that letter!"},
  }


  def move_status(status) do
    {class, message} = @status_fields[status]
    "<div class='status #{class}'>#{message}</div>"
  end

  def continue_or_try_again(conn, status) when status in [:won, :lost] do
    button("Try again", to: Routes.hangman_path(conn, :new))
  end

  def continue_or_try_again(conn, _) do
    form_for(conn, Routes.hangman_path(conn, :update), [ as: "make_move", method: :put ], fn f ->
     [
      text_input(f, :guess),
      " ",
      submit("Make next guess")
     ]
   end)
  end

  defdelegate figure_for(turns_left), to: B1Web.HangmanView.Helpers.FigureFor

end
