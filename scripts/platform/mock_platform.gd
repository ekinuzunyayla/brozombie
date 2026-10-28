class_name MockPlatform
extends Platform
## Editör ve debug build'ler için sahte platform. Açılan başarımları bellekte tutar.

var _unlocked: Dictionary[StringName, bool] = {}


func unlock_achievement(achievement_id: StringName) -> void:
	_unlocked[achievement_id] = true


func is_achievement_unlocked(achievement_id: StringName) -> bool:
	return _unlocked.has(achievement_id)
