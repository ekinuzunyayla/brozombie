class_name Stats
extends RefCounted
## Taban değerler + modifier listesi. Bir stat'ın değeri her zaman buradan hesaplanır:
## (taban + düz eklemeler) * (1 + yüzdelerin toplamı / 100). Çarpan 0'ın altına inmez.
## Her modifier bir kaynakla eklenir (ör. kart id'si), böylece kaynağın tüm etkisi tek seferde geri alınır.

signal stat_changed(stat: StringName)


class _Entry:
	var modifier: StatModifier
	var source: StringName

	func _init(p_modifier: StatModifier, p_source: StringName) -> void:
		modifier = p_modifier
		source = p_source


var _base: Dictionary[StringName, float] = {}
var _entries: Array[_Entry] = []
var _cache: Dictionary[StringName, float] = {}


func set_base(stat: StringName, value: float) -> void:
	_base[stat] = value
	_invalidate(stat)


func get_base(stat: StringName) -> float:
	return _base.get(stat, 0.0)


## Tanımsız stat 0 döner.
func get_value(stat: StringName) -> float:
	if _cache.has(stat):
		return _cache[stat]
	var value: float = apply(stat, get_base(stat))
	_cache[stat] = value
	return value


## Bu stat'ın modifier'larını kendi tabanı yerine verilen tabana uygular.
## Ör. silahın hasarı `apply(StatIds.DAMAGE, weapon_damage)` ile oyuncunun hasar kartlarından etkilenir.
func apply(stat: StringName, base: float) -> float:
	var flat: float = base
	var percent: float = 0.0
	for entry in _entries:
		if entry.modifier.stat != stat:
			continue
		match entry.modifier.type:
			StatModifier.Type.FLAT:
				flat += entry.modifier.value
			StatModifier.Type.PERCENT:
				percent += entry.modifier.value
	return flat * maxf(0.0, 1.0 + percent / 100.0)


func add_modifier(modifier: StatModifier, source: StringName = &"") -> void:
	_entries.append(_Entry.new(modifier, source))
	_invalidate(modifier.stat)


func add_modifiers(modifiers: Array[StatModifier], source: StringName = &"") -> void:
	for modifier in modifiers:
		add_modifier(modifier, source)


## Kaynaktan gelen bütün modifier'ları kaldırır (ör. koşullu kartın etkisi bitince).
func remove_source(source: StringName) -> void:
	var changed: Dictionary[StringName, bool] = {}
	for i in range(_entries.size() - 1, -1, -1):
		if _entries[i].source == source:
			changed[_entries[i].modifier.stat] = true
			_entries.remove_at(i)
	for stat in changed:
		_invalidate(stat)


func has_source(source: StringName) -> bool:
	return _entries.any(func(entry: _Entry) -> bool: return entry.source == source)


func to_dict() -> Dictionary:
	var base: Dictionary = {}
	for stat in _base:
		base[String(stat)] = _base[stat]
	var modifiers: Array[Dictionary] = []
	for entry in _entries:
		var data: Dictionary = entry.modifier.to_dict()
		data["source"] = String(entry.source)
		modifiers.append(data)
	return {"base": base, "modifiers": modifiers}


static func from_dict(data: Dictionary) -> Stats:
	var stats := Stats.new()
	var base: Dictionary = data.get("base", {})
	for stat in base:
		stats._base[StringName(stat)] = float(base[stat])
	for modifier_data: Dictionary in data.get("modifiers", []):
		stats._entries.append(_Entry.new(StatModifier.from_dict(modifier_data), StringName(modifier_data.get("source", ""))))
	return stats


func _invalidate(stat: StringName) -> void:
	_cache.erase(stat)
	stat_changed.emit(stat)
