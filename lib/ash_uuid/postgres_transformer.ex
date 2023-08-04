defmodule AshUUID.PostgresTransformer do
  @moduledoc "Set default values"

  use Spark.Dsl.Transformer

  alias Spark.Dsl.Transformer

  def transform(dsl) do
    attributes = Transformer.get_entities(dsl, [:attributes])

    migration_defaults = attributes
    |> Enum.filter(fn
      %{type: AshUUID.RawV4, constraints: [prefix: _, migration_default?: true]} -> true
      %{type: AshUUID.RawV7, constraints: [prefix: _, migration_default?: true]} -> true
      %{type: AshUUID.EncodedV4, constraints: [prefix: _, migration_default?: true]} -> true
      %{type: AshUUID.EncodedV7, constraints: [prefix: _, migration_default?: true]} -> true
      %{type: AshUUID.PrefixedV4, constraints: [prefix: _, migration_default?: true]} -> true
      %{type: AshUUID.PrefixedV7, constraints: [prefix: _, migration_default?: true]} -> true
      _ -> false
    end)
    |> Enum.map(fn
      %{name: name, type: AshUUID.RawV4} -> {name, "fragment(\"uuid_generate_v4()\")"}
      %{name: name, type: AshUUID.RawV7} -> {name, "fragment(\"uuid_generate_v7()\")"}
      %{name: name, type: AshUUID.EncodedV4} -> {name, "fragment(\"uuid_generate_v4()\")"}
      %{name: name, type: AshUUID.EncodedV7} -> {name, "fragment(\"uuid_generate_v7()\")"}
      %{name: name, type: AshUUID.PrefixedV4} -> {name, "fragment(\"uuid_generate_v4()\")"}
      %{name: name, type: AshUUID.PrefixedV7} -> {name, "fragment(\"uuid_generate_v7()\")"}
    end)
    |> Keyword.merge(Transformer.get_option(dsl, [:postgres], :migration_defaults))

    dsl = Transformer.set_option(dsl, [:postgres], :migration_defaults, migration_defaults)

    {:ok, dsl}
  end
end
