class_name NodePool
extends Node2D
## Aynı sahneden üretilen node'ları yok etmek yerine saklayıp yeniden kullanır (mermi, zombi, drop).
## Boştaki node gizlenir ve işlenmez; fizik nesneleri bu sırada fizik dünyasından çıkar.

@export var scene: PackedScene

var _free: Array[Node] = []


func acquire() -> Node:
	var node: Node
	if _free.is_empty():
		node = scene.instantiate()
		add_child(node)
	else:
		node = _free.pop_back()
	node.process_mode = Node.PROCESS_MODE_INHERIT
	node.show()
	return node


## Fizik geri çağrısının içinden de güvenle çağrılabilir: node bir sonraki boşta havuza girer.
## Böylece aynı karede yeniden alınıp ardından yanlışlıkla kapatılmaz.
func release(node: Node) -> void:
	_park.call_deferred(node)


func free_count() -> int:
	return _free.size()


func _park(node: Node) -> void:
	if node in _free:
		return
	node.hide()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	_free.append(node)
