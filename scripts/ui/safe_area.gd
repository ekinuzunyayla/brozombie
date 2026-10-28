class_name SafeArea
extends MarginContainer
## Çocuklarını cihazın güvenli alanına (çentik, yuvarlak köşe, gesture çubuğu) sığdırır.
## Masaüstünde boşluk eklemez.


func _ready() -> void:
	get_viewport().size_changed.connect(_update_margins)
	_update_margins()


func _update_margins() -> void:
	var left: float = 0.0
	var top: float = 0.0
	var right: float = 0.0
	var bottom: float = 0.0
	if OS.has_feature("mobile"):
		var window_size := Vector2(DisplayServer.window_get_size())
		var safe := Rect2(DisplayServer.get_display_safe_area())
		# Güvenli alan piksel cinsinden gelir, stretch sonrası görüntü alanı birimine çevrilir.
		var to_viewport: Vector2 = get_viewport_rect().size / window_size
		left = safe.position.x * to_viewport.x
		top = safe.position.y * to_viewport.y
		right = (window_size.x - safe.end.x) * to_viewport.x
		bottom = (window_size.y - safe.end.y) * to_viewport.y
	add_theme_constant_override("margin_left", roundi(left))
	add_theme_constant_override("margin_top", roundi(top))
	add_theme_constant_override("margin_right", roundi(right))
	add_theme_constant_override("margin_bottom", roundi(bottom))
