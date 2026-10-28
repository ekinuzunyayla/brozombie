class_name Monetization
extends RefCounted
## Reklam ve uygulama içi satın alma arayüzü. Oyun kodu yalnızca bu sınıfı tanır.
## Bu temel sınıf hiçbir şey yapmaz (PC premium sürüm): reklam hazır değildir, satın alma başarısız olur.
## Mobil SDK'lar ve editör mock'u bunu genişletir.

## Ödüllü reklam kapandığında. `rewarded` false ise oyuncu reklamı yarıda bırakmıştır.
signal rewarded_ad_finished(placement: StringName, rewarded: bool)
signal purchase_finished(product_id: StringName, success: bool)


func is_rewarded_ad_ready(_placement: StringName) -> bool:
	return false


## Sonuç `rewarded_ad_finished` ile gelir. Hazır değilse hemen `rewarded = false` döner.
func show_rewarded_ad(placement: StringName) -> void:
	rewarded_ad_finished.emit.call_deferred(placement, false)


## Sonuç `purchase_finished` ile gelir.
func purchase(product_id: StringName) -> void:
	purchase_finished.emit.call_deferred(product_id, false)


func is_owned(_product_id: StringName) -> bool:
	return false
