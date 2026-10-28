class_name StatIds
extends RefCounted
## Oyuncu, silah ve yapı statlarının adları. Kod ve `.tres` dosyaları bu adları kullanır.

const MAX_HP: StringName = &"max_hp"
const MOVE_SPEED: StringName = &"move_speed"
const DAMAGE: StringName = &"damage"
const ATTACK_SPEED: StringName = &"attack_speed"
const RANGE: StringName = &"range"
const MAGAZINE_SIZE: StringName = &"magazine_size"
const RELOAD_TIME: StringName = &"reload_time"
const CRIT_CHANCE: StringName = &"crit_chance"
const PICKUP_RANGE: StringName = &"pickup_range"
const ARMOR: StringName = &"armor"

const ALL: Array[StringName] = [
	MAX_HP, MOVE_SPEED, DAMAGE, ATTACK_SPEED, RANGE,
	MAGAZINE_SIZE, RELOAD_TIME, CRIT_CHANCE, PICKUP_RANGE, ARMOR,
]
