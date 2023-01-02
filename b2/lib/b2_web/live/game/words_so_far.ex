defmodule B2Web.Live.Game.WordsSoFar do
alias B2Web.Live.Game.WordsSoFar

  use B2Web, :live_component

  @states %{
    already_used: "Already Used",
    bad_guess: "Bad Guess",
    good_guess: "Good Guess",
    initializing: "Type or click a letter",
    lost: "You Lost",
    won: "You Won"
  }
  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="word-so-far">
      <div class="game-state">
        <%= state_name(@tally.game_state) %>
      </div>
      <div class="letters">
      <%= for ch <- @tally.letters do %>
        <% cls = if ch != "_", do: "one-letter correct", else: "one-letter" %>
          <div class={cls}>
            <%= ch %>
          </div>
      <% end %>
      </div>
    </div>
    """
  end

  defp state_name(state) do
      @states[state] || "Uknown State"
  end
end
