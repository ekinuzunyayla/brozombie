extends GutTest

var _stats: Stats


func before_each() -> void:
	_stats = Stats.new()
	_stats.set_base(StatIds.MAX_HP, 100.0)


func _flat(stat: StringName, value: float) -> StatModifier:
	return StatModifier.create(stat, StatModifier.Type.FLAT, value)


func _percent(stat: StringName, value: float) -> StatModifier:
	return StatModifier.create(stat, StatModifier.Type.PERCENT, value)


func test_value_without_modifiers_is_base() -> void:
	assert_eq(_stats.get_value(StatIds.MAX_HP), 100.0)


func test_undefined_stat_is_zero() -> void:
	assert_eq(_stats.get_value(StatIds.ARMOR), 0.0)


func test_flat_modifiers_add() -> void:
	_stats.add_modifier(_flat(StatIds.MAX_HP, 20.0))
	_stats.add_modifier(_flat(StatIds.MAX_HP, -5.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 115.0)


func test_percent_applies_after_flat() -> void:
	_stats.add_modifier(_percent(StatIds.MAX_HP, 50.0))
	_stats.add_modifier(_flat(StatIds.MAX_HP, 20.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 180.0)


# Yüzdeler bileşik değil, toplanarak uygulanır: +%50 ve +%50 = +%100.
func test_percents_are_additive() -> void:
	_stats.add_modifier(_percent(StatIds.MAX_HP, 50.0))
	_stats.add_modifier(_percent(StatIds.MAX_HP, 50.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 200.0)


func test_negative_percent_does_not_go_below_zero() -> void:
	_stats.add_modifier(_percent(StatIds.MAX_HP, -150.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 0.0)


func test_modifier_only_affects_its_stat() -> void:
	_stats.set_base(StatIds.DAMAGE, 10.0)
	_stats.add_modifier(_percent(StatIds.DAMAGE, 30.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 100.0)
	assert_almost_eq(_stats.get_value(StatIds.DAMAGE), 13.0, 0.0001)


func test_tradeoff_card_changes_two_stats() -> void:
	_stats.set_base(StatIds.DAMAGE, 10.0)
	_stats.set_base(StatIds.MOVE_SPEED, 200.0)
	var modifiers: Array[StatModifier] = [_percent(StatIds.DAMAGE, 30.0), _percent(StatIds.MOVE_SPEED, -15.0)]
	_stats.add_modifiers(modifiers, &"card_glass_cannon")
	assert_almost_eq(_stats.get_value(StatIds.DAMAGE), 13.0, 0.0001)
	assert_almost_eq(_stats.get_value(StatIds.MOVE_SPEED), 170.0, 0.0001)


func test_remove_source_reverts_only_that_source() -> void:
	_stats.add_modifier(_flat(StatIds.MAX_HP, 20.0), &"card_thick_skin")
	_stats.add_modifier(_percent(StatIds.MAX_HP, 50.0), &"adrenaline")
	_stats.remove_source(&"adrenaline")
	assert_eq(_stats.get_value(StatIds.MAX_HP), 120.0)
	assert_false(_stats.has_source(&"adrenaline"))
	assert_true(_stats.has_source(&"card_thick_skin"))


func test_cache_is_invalidated_on_change() -> void:
	assert_eq(_stats.get_value(StatIds.MAX_HP), 100.0)
	_stats.add_modifier(_flat(StatIds.MAX_HP, 1.0))
	assert_eq(_stats.get_value(StatIds.MAX_HP), 101.0)
	_stats.set_base(StatIds.MAX_HP, 50.0)
	assert_eq(_stats.get_value(StatIds.MAX_HP), 51.0)


func test_changes_emit_stat_changed() -> void:
	watch_signals(_stats)
	_stats.add_modifier(_flat(StatIds.ARMOR, 2.0), &"card")
	assert_signal_emitted_with_parameters(_stats, "stat_changed", [StatIds.ARMOR])
	_stats.remove_source(&"card")
	assert_signal_emit_count(_stats, "stat_changed", 2)


func test_round_trip_through_dict() -> void:
	_stats.set_base(StatIds.DAMAGE, 10.0)
	_stats.add_modifier(_flat(StatIds.MAX_HP, 20.0), &"card_thick_skin")
	_stats.add_modifier(_percent(StatIds.DAMAGE, -25.0), &"curse")
	var restored: Stats = Stats.from_dict(JSON.parse_string(JSON.stringify(_stats.to_dict())))
	assert_eq(restored.get_value(StatIds.MAX_HP), 120.0)
	assert_almost_eq(restored.get_value(StatIds.DAMAGE), 7.5, 0.0001)
	restored.remove_source(&"card_thick_skin")
	assert_eq(restored.get_value(StatIds.MAX_HP), 100.0)


func test_stat_ids_are_unique() -> void:
	var seen: Dictionary[StringName, bool] = {}
	for stat in StatIds.ALL:
		assert_false(seen.has(stat), "%s iki kez tanımlı" % stat)
		seen[stat] = true
