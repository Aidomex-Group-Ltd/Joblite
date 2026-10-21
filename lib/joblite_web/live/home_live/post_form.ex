defmodule JobliteWeb.HomeLive.PostForm do
  @moduledoc "Validates preview text and opaque browser references, never client-supplied URLs."
  @types %{"image" => ~w(image/jpeg image/png image/webp), "video" => ~w(video/mp4 video/webm)}

  @spec parse(term()) :: {:ok, map()} | {:error, String.t()}
  def parse(%{"body" => body, "media" => media}) when is_binary(body) and is_list(media) do
    body = String.trim(body)

    cond do
      String.length(body) > 600 -> {:error, "Keep your post to 600 characters."}
      length(media) > 4 -> {:error, "Choose up to four attachments."}
      body == "" and media == [] -> {:error, "Add some text or media first."}
      true -> parse_media(body, media)
    end
  end

  def parse(_params), do: {:error, "The post could not be read. Try again."}

  defp parse_media(body, entries) do
    parsed = Enum.map(entries, &parse_entry/1)

    cond do
      :error in parsed ->
        {:error, "One of the media references is invalid. Choose the file again."}

      Enum.count(parsed, &(&1.kind == "video")) > 1 ->
        {:error, "Choose one video per post."}

      length(Enum.uniq_by(parsed, & &1.id)) != length(parsed) ->
        {:error, "Remove duplicate attachments."}

      true ->
        {:ok, %{body: body, media: parsed}}
    end
  end

  defp parse_entry(%{"id" => id, "kind" => kind, "type" => type, "name" => name})
       when is_binary(id) and is_binary(kind) and is_binary(type) and is_binary(name) do
    if String.length(id) <= 80 and Regex.match?(~r/^local-[a-zA-Z0-9-]+$/, id) and
         type in Map.get(@types, kind, []) and String.length(name) in 1..100 do
      %{id: id, kind: kind, local: true, source: nil, thumbnail: nil, alt: name, duration: nil}
    else
      :error
    end
  end

  defp parse_entry(_entry), do: :error
end
