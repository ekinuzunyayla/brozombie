class_name Platform
extends RefCounted
## Mağaza/platform servisleri arayüzü: başarımlar ve bulut kaydı.
## Bu temel sınıf hiçbir şey yapmaz. Steam, Game Center ve Google Play uygulamaları bunu genişletir.


func unlock_achievement(_achievement_id: StringName) -> void:
	pass


func is_achievement_unlocked(_achievement_id: StringName) -> bool:
	return false


## Bulut kaydı destekleniyorsa true. Desteklenmiyorsa kayıt yalnızca `user://` altında kalır.
func supports_cloud_save() -> bool:
	return false
