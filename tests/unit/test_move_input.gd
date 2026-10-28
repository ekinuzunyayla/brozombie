extends GutTest


func after_each() -> void:
	for action in [MoveInput.ACTION_LEFT, MoveInput.ACTION_RIGHT, MoveInput.ACTION_UP, MoveInput.ACTION_DOWN]:
		Input.action_release(action)


func test_no_input_is_zero() -> void:
	assert_eq(MoveInput.get_vector(), Vector2.ZERO)


func test_full_press_gives_unit_direction() -> void:
	Input.action_press(MoveInput.ACTION_RIGHT)
	assert_almost_eq(MoveInput.get_vector(), Vector2.RIGHT, Vector2(0.001, 0.001))


func test_diagonal_is_clamped_to_unit_length() -> void:
	Input.action_press(MoveInput.ACTION_RIGHT)
	Input.action_press(MoveInput.ACTION_UP)
	assert_almost_eq(MoveInput.get_vector().length(), 1.0, 0.001)


# Joystick ve analog çubuk eylemlere kısmi güç yazar.
func test_partial_strength_gives_slow_walk() -> void:
	Input.action_press(MoveInput.ACTION_LEFT, 0.6)
	var vector: Vector2 = MoveInput.get_vector()
	assert_lt(vector.x, 0.0)
	assert_gt(vector.x, -1.0)


func test_strength_below_dead_zone_is_ignored() -> void:
	Input.action_press(MoveInput.ACTION_LEFT, 0.1)
	assert_eq(MoveInput.get_vector(), Vector2.ZERO)
