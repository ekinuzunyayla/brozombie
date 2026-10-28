class_name FlowField
extends RefCounted
## Izgara üzerinde hedefe giden yol haritası. Hedef kareden genişlik öncelikli arama yapılır ve
## her yürünebilir kare için hedefe bir adım yaklaştıran komşu kare saklanır.
## Bütün zombiler aynı alanı paylaşır; zombi sayısı arttıkça maliyet artmaz.

const NO_CELL: int = -1
const _NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

var size: Vector2i
var _walkable: PackedByteArray
var _distance: PackedInt32Array
var _next: PackedInt32Array
var _target: Vector2i = Vector2i(-1, -1)


func _init(p_size: Vector2i) -> void:
	size = p_size
	_walkable.resize(size.x * size.y)
	_walkable.fill(1)
	_distance.resize(size.x * size.y)
	_next.resize(size.x * size.y)
	_distance.fill(-1)
	_next.fill(NO_CELL)


func set_walkable(cell: Vector2i, walkable: bool) -> void:
	if is_inside(cell):
		_walkable[_index(cell)] = 1 if walkable else 0


func is_walkable(cell: Vector2i) -> bool:
	return is_inside(cell) and _walkable[_index(cell)] == 1


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func get_target() -> Vector2i:
	return _target


## Hedef değişmediyse yeniden hesaplamaz.
func compute(target: Vector2i) -> void:
	if target == _target:
		return
	_target = target
	_distance.fill(-1)
	_next.fill(NO_CELL)
	if not is_walkable(target):
		return
	var queue: Array[Vector2i] = [target]
	_distance[_index(target)] = 0
	var head: int = 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		var step: int = _distance[_index(cell)] + 1
		for offset in _NEIGHBORS:
			var neighbor: Vector2i = cell + offset
			if not _can_step(cell, offset) or _distance[_index(neighbor)] != -1:
				continue
			_distance[_index(neighbor)] = step
			_next[_index(neighbor)] = _index(cell)
			queue.append(neighbor)


## Hedefe kaç adım var. Ulaşılamıyorsa -1.
func get_distance(cell: Vector2i) -> int:
	return _distance[_index(cell)] if is_inside(cell) else -1


## Hedefe bir adım yaklaştıran kare. Hedefin kendisinde, ulaşılamayan ya da alan dışı karede -1,-1.
func get_next_cell(cell: Vector2i) -> Vector2i:
	if not is_inside(cell):
		return Vector2i(-1, -1)
	var next: int = _next[_index(cell)]
	if next == NO_CELL:
		return Vector2i(-1, -1)
	return Vector2i(next % size.x, next / size.x)


# Çapraz adımda iki yan kare de açık olmalı, yoksa zombi duvar köşesinden geçmeye çalışır.
func _can_step(from: Vector2i, offset: Vector2i) -> bool:
	if not is_walkable(from + offset):
		return false
	if offset.x != 0 and offset.y != 0:
		return is_walkable(from + Vector2i(offset.x, 0)) and is_walkable(from + Vector2i(0, offset.y))
	return true


func _index(cell: Vector2i) -> int:
	return cell.y * size.x + cell.x
