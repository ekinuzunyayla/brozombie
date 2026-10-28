class_name StatModifier
extends Resource
## Bir stat'a uygulanan tek değişiklik. Kartlar ve yükseltmeler stat'ı değiştirmez, modifier ekler.

enum Type {
	FLAT, ## Taban değere eklenir (ör. +20 max can).
	PERCENT, ## Yüzde puanı; aynı stat'taki yüzdeler toplanır, sonra çarpılır (ör. -20 = %20 azalma).
}

@export var stat: StringName
@export var type: Type = Type.FLAT
@export var value: float = 0.0


static func create(p_stat: StringName, p_type: Type, p_value: float) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat = p_stat
	modifier.type = p_type
	modifier.value = p_value
	return modifier


func to_dict() -> Dictionary:
	return {"stat": String(stat), "type": type, "value": value}


static func from_dict(data: Dictionary) -> StatModifier:
	return create(StringName(data["stat"]), data["type"] as Type, float(data["value"]))
