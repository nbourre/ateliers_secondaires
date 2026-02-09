extends ObjectPool


func get_instance() -> Node:
	if (_available.size() > 0):
		var obj = _available.pop_front() as Meteorite
		_in_use.append(obj)
		return obj
	else:
		var obj = scene_to_instance.instantiate() as Meteorite
		_in_use.append(obj)
		return obj

func release_instance(instance : Node) -> void:
	reset (instance as Meteorite)

	_available.append(instance as Meteorite)
	_in_use.erase(instance as Meteorite)

func reset(m : Meteorite) -> void:
	m.reset()