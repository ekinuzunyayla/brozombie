class_name MockMonetization
extends Monetization
## Editör ve debug build'ler için sahte reklam/satın alma. Reklamlar her zaman ödül verir,
## satın almalar başarılı olur ve yalnızca bellekte tutulur.

## Testler reklam reddini ve satın alma hatasını deneyebilsin diye değiştirilebilir.
var ads_rewarded: bool = true
var purchases_succeed: bool = true

var _owned: Dictionary[StringName, bool] = {}


func is_rewarded_ad_ready(_placement: StringName) -> bool:
	return true


func show_rewarded_ad(placement: StringName) -> void:
	rewarded_ad_finished.emit.call_deferred(placement, ads_rewarded)


func purchase(product_id: StringName) -> void:
	if purchases_succeed:
		_owned[product_id] = true
	purchase_finished.emit.call_deferred(product_id, purchases_succeed)


func is_owned(product_id: StringName) -> bool:
	return _owned.has(product_id)
