class_name FlowFieldSystem
extends Node
## Haritanın duvar katmanından akış alanını kurar ve hedef (oyuncu) başka bir kareye geçince günceller.
## Zombiler yön için buraya sorar.

var target: Node2D

var _field: FlowField
var _walls: TileMapLayer
var _origin: Vector2i


func setup(map: GameMap, p_target: Node2D) -> void:
	target = p_target
	_walls = map.walls
	var used: Rect2i = map.ground.get_used_rect()
	_origin = used.position
	_field = FlowField.new(used.size)
	for y in used.size.y:
		for x in used.size.x:
			var cell := Vector2i(x, y)
			_field.set_walkable(cell, _walls.get_cell_source_id(cell + _origin) == -1)
	_update()


func _physics_process(_delta: float) -> void:
	_update()


## Bu konumdaki zombinin yürümesi gereken yön (birim vektör). Hedefin karesinde ya da yol yoksa
## doğrudan hedefe bakar.
func get_direction(from: Vector2) -> Vector2:
	if _field == null or target == null:
		return Vector2.ZERO
	var next: Vector2i = _field.get_next_cell(_to_cell(from))
	var goal: Vector2 = target.global_position
	if next != Vector2i(-1, -1) and next != _field.get_target():
		goal = _walls.to_global(_walls.map_to_local(next + _origin))
	return from.direction_to(goal)


func _update() -> void:
	if _field and target:
		_field.compute(_to_cell(target.global_position))


func _to_cell(world: Vector2) -> Vector2i:
	return _walls.local_to_map(_walls.to_local(world)) - _origin
