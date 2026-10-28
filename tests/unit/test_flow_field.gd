extends GutTest

const GameScene: PackedScene = preload("res://scenes/game/game.tscn")


# Ortada (2,0)-(2,3) duvarı olan 5x5 ızgara; geçit yalnızca alt satırda (2,4).
func _field_with_wall() -> FlowField:
	var field := FlowField.new(Vector2i(5, 5))
	for y in 4:
		field.set_walkable(Vector2i(2, y), false)
	return field


func test_open_grid_steps_toward_target() -> void:
	var field := FlowField.new(Vector2i(5, 5))
	field.compute(Vector2i(4, 2))
	assert_eq(field.get_next_cell(Vector2i(0, 2)), Vector2i(1, 2))
	assert_eq(field.get_distance(Vector2i(0, 2)), 4)


func test_target_cell_has_no_next() -> void:
	var field := FlowField.new(Vector2i(5, 5))
	field.compute(Vector2i(2, 2))
	assert_eq(field.get_next_cell(Vector2i(2, 2)), Vector2i(-1, -1))
	assert_eq(field.get_distance(Vector2i(2, 2)), 0)


func test_path_goes_around_wall() -> void:
	var field := _field_with_wall()
	field.compute(Vector2i(4, 0))
	# (0,0)'dan düz sağa gidilemez; yol alttaki geçitten dolaşır.
	var cell := Vector2i(0, 0)
	var steps: int = 0
	while cell != Vector2i(4, 0) and steps < 30:
		cell = field.get_next_cell(cell)
		assert_true(field.is_walkable(cell), "%s duvar" % cell)
		steps += 1
	assert_eq(cell, Vector2i(4, 0))
	assert_gt(steps, 4, "Yol duvarın etrafından dolaşmalı")


func test_no_diagonal_through_wall_corner() -> void:
	var field := FlowField.new(Vector2i(3, 3))
	field.set_walkable(Vector2i(1, 0), false)
	field.compute(Vector2i(2, 0))
	# (1,1)'den (2,0)'a çapraz adım (1,0) duvarının köşesinden geçerdi.
	assert_ne(field.get_next_cell(Vector2i(1, 1)), Vector2i(2, 0))


func test_unreachable_cell_has_no_path() -> void:
	var field := FlowField.new(Vector2i(5, 5))
	for y in 5:
		field.set_walkable(Vector2i(2, y), false)
	field.compute(Vector2i(4, 2))
	assert_eq(field.get_distance(Vector2i(0, 2)), -1)
	assert_eq(field.get_next_cell(Vector2i(0, 2)), Vector2i(-1, -1))


func test_zombie_reaches_player_inside_house() -> void:
	var game: Node = GameScene.instantiate()
	add_child_autofree(game)
	game.get_node("%ZombieSpawner").process_mode = Node.PROCESS_MODE_DISABLED
	var player: Player = game.get_node("%Player")
	player.weapon.process_mode = Node.PROCESS_MODE_DISABLED
	await wait_physics_frames(2)
	var map: GameMap = game.get_node("%Map")
	var zombie: Zombie = game.get_node("%ZombiePool").acquire()
	var runner: ZombieData = load("res://data/zombies/runner.tres")
	# Sol üst köşe: oyuncuya düz çizgide evin duvarı var.
	zombie.setup(runner, player, player.health, map.get_zombie_spawn_points()[0], game._flow)
	await wait_seconds(12.0)
	assert_lt(zombie.global_position.distance_to(player.global_position), runner.attack_range + 10.0)
