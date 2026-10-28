extends Node
## Uygulama genelindeki durum: ayarlar, dil ve platform servisleri. Oyun mantığı burada yaşamaz.

signal locale_changed(locale: String)
## Mobilde uygulama arka plana geçti. Oyun sahnesi bunu dinleyip duraklatma menüsünü açar.
signal app_backgrounded

const SUPPORTED_LOCALES: Array[String] = ["tr", "en"]
const DEFAULT_LOCALE: String = "en"
const SETTINGS_PATH: String = "user://settings.cfg"

## Testler kendi geçici dosyalarını kullanabilsin diye değiştirilebilir.
var settings_path: String = SETTINGS_PATH
var monetization: Monetization
var platform: Platform


func _ready() -> void:
	_create_platform_services()
	set_locale(_load_locale(), false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if OS.has_feature("mobile"):
			app_backgrounded.emit()


# Gerçek SDK uygulamaları gelene kadar: debug build'de mock, release'de hiçbir şey yapmayan temel sınıf.
# Mock'un release'e girmesi bedava satın alma demek olurdu.
func _create_platform_services() -> void:
	if OS.is_debug_build():
		monetization = MockMonetization.new()
		platform = MockPlatform.new()
	else:
		monetization = Monetization.new()
		platform = Platform.new()


# --- Dil ---

func get_locale() -> String:
	return TranslationServer.get_locale()


func set_locale(locale: String, save: bool = true) -> void:
	if locale not in SUPPORTED_LOCALES:
		locale = DEFAULT_LOCALE
	TranslationServer.set_locale(locale)
	if save:
		_save_setting("locale", locale)
	locale_changed.emit(locale)


## Desteklenen diller arasında sıradakine geçer.
func cycle_locale() -> void:
	var index: int = SUPPORTED_LOCALES.find(get_locale())
	set_locale(SUPPORTED_LOCALES[(index + 1) % SUPPORTED_LOCALES.size()])


# İlk açılışta cihaz dili desteklenmiyorsa varsayılan dil kullanılır.
func _load_locale() -> String:
	var config := ConfigFile.new()
	if config.load(settings_path) == OK:
		return str(config.get_value("general", "locale", DEFAULT_LOCALE))
	var system_language: String = OS.get_locale_language()
	return system_language if system_language in SUPPORTED_LOCALES else DEFAULT_LOCALE


func _save_setting(key: String, value: Variant) -> void:
	var config := ConfigFile.new()
	config.load(settings_path) # Dosya yoksa yeni oluşturulur.
	config.set_value("general", key, value)
	config.save(settings_path)
