class_name ZombieData
extends Resource
## Zombi tipi. Yeni zombi = yeni `.tres`; davranış farkları buradaki değerlerden gelir.

@export var id: StringName
@export var name_key: String
@export var max_health: float = 20.0
## px/s.
@export var speed: float = 60.0
@export var damage: float = 10.0
## Bu mesafeden yakındaki hedefe vurur (px, merkezden merkeze).
@export var attack_range: float = 50.0
## Saniye.
@export var attack_interval: float = 1.0
@export var barricade_damage_mult: float = 1.0
@export var xp_value: int = 1
@export var money_value: int = 5
@export var scene: PackedScene

@export_group("Placeholder Görünüm")
@export var radius: float = 24.0
@export var color: Color = Color.OLIVE_DRAB
