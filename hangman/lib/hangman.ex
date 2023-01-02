defmodule Hangman do
  alias Hangman.Runtime.Server
  alias Hangman.Type

  # An opaque type, defined with @opaque is a type where the internal structure of the type will not be visible, but the type is still public.
  @opaque game :: Server.t()

  @spec new_game :: game
  def new_game do
    {:ok, pid} = Hangman.Runtime.Application.start_game
    pid
  end

  @spec make_move(game, String.t()) :: {game, Type.tally()}
  def make_move(game, guess) do
    GenServer.call(game, {:make_move, guess})
  end

  @spec tally(game) :: Type.tally()
  def tally(game) do
    GenServer.call(game, {:tally})
  end
end
