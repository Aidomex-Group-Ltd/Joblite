defmodule JobliteWeb.ExploreLive.DirectoryFilters do
  @moduledoc """
  The filter state of the job board directory.
  """
  defstruct text: "", region: nil

  @spec new() :: %__MODULE__{}
  def new, do: %__MODULE__{}

  @doc "Reads the filters of a submitted form."
  @spec apply(%__MODULE__{}, map()) :: %__MODULE__{}
  def apply(%__MODULE__{} = filters, params) do
    %{
      filters
      | text: text(params),
        region: region(params)
    }
  end

  @doc "The filters in the shape the directory query expects."
  @spec to_query(%__MODULE__{}) :: map()
  def to_query(%__MODULE__{text: text, region: region}) do
    %{text: text, region: region}
  end

  defp text(params) do
    case params["text"] do
      value when is_binary(value) -> String.trim(value)
      _other -> ""
    end
  end

  defp region(params) do
    case params["region"] do
      value when is_binary(value) ->
        if value in ~w(global africa europe north_america latin_america asia_pacific_mena),
          do: value,
          else: nil

      _other ->
        nil
    end
  end
end
