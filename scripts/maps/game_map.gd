class_name GameMap
extends Node2D
## Bir harita sahnesinin kökü. Zemin ve duvar katmanlarını, oyuncu başlangıç noktasını tanır.

@onready var ground: TileMapLayer = %Ground
@onready var walls: TileMapLayer = %Walls
@onready var player_spawn: Marker2D = %PlayerSpawn
@onready var _zombie_spawns: Node2D = %ZombieSpawns


## Zombi giriş noktaları (dünya koordinatı).
func get_zombie_spawn_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for marker in _zombie_spawns.get_children():
		points.append((marker as Node2D).global_position)
	return points


## Haritanın dünya koordinatlarındaki sınırı (kamera sınırları için).
func get_bounds() -> Rect2:
	var cells: Rect2i = ground.get_used_rect()
	var tile_size := Vector2(ground.tile_set.tile_size)
	return Rect2(ground.to_global(Vector2(cells.position) * tile_size), Vector2(cells.size) * tile_size)
