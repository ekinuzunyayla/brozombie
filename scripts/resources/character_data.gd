class_name CharacterData
extends Resource
## Oynanabilir karakter tanımı. Taban statlar burada, run içi değişiklikler `Stats` modifier'larıyla gelir.

@export var id: StringName
@export var name_key: String
## `StatIds` adlarıyla taban değerler.
@export var base_stats: Dictionary[StringName, float] = {}


func create_stats() -> Stats:
	var stats := Stats.new()
	for stat in base_stats:
		stats.set_base(stat, base_stats[stat])
	return stats
