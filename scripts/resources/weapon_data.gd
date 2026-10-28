class_name WeaponData
extends Resource
## Silah tanımı. Değerler tabandır; oyuncunun stat modifier'ları üstüne uygulanır.

@export var id: StringName
@export var name_key: String
@export var damage: float = 10.0
## Saniyedeki atış.
@export var attack_speed: float = 2.0
## Hedef seçme ve merminin gidebileceği mesafe (px).
@export var max_range: float = 600.0
@export var projectile_speed: float = 1400.0
@export var magazine_size: int = 12
## Saniye.
@export var reload_time: float = 1.2
## Atış başına rastgele sapma (derece, iki yöne).
@export var spread_degrees: float = 0.0
## Yüzde (0-100).
@export var crit_chance: float = 5.0
@export var crit_multiplier: float = 2.0
@export var projectile_scene: PackedScene
