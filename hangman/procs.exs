defmodule Procs do
  def hello() do
    receive do
      [a,b] ->
       IO.puts("Hello #{inspect a}!  #{inspect b}")
       hello()
    end

  end
end
