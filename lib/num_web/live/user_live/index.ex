defmodule NumWeb.UserLive.Index do
  use NumWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do

    Process.send_after(self(), :update, 25)

    num =
    1..25
    |> Enum.shuffle()

    questions =
    num
    |> Enum.shuffle()

    questions = questions ++ [nil]
    [question | questions] = questions

    start_time = DateTime.utc_now()
    socket = assign(socket, num: num)
    |> assign(ok_num: [])
    |> assign(questions: questions)
    |> assign(question: question)
    |> assign(start_time: start_time)
    |> assign(time: nil)

    {:ok, socket}
  end

  @impl true
  def handle_info(:update, socket) do
    start_time = socket.assigns[:start_time]
    ok_num = socket.assigns[:ok_num]

    time = if length(ok_num) < 25 do
      Process.send_after(self(), :update, 25)
      DateTime.diff(DateTime.utc_now, start_time, :microsecond) / 1000000
    else
      socket.assigns[:time]
    end

    socket = assign(socket, time: time)
    {:noreply, socket}
  end

  @impl true
  def handle_event("buttno", %{"no" => no}, socket) do
    question = socket.assigns[:question]
    |> Integer.to_string()

    socket = if question == no do
      ok_num = socket.assigns[:ok_num] ++ [no]
      [question | questions] = socket.assigns[:questions]
      assign(socket, ok_num: ok_num)
      |> assign(questions: questions)
      |> assign(question: question)
    else
      socket
    end

    {:noreply, socket}
  end

end
