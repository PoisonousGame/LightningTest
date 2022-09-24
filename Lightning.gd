extends Node2D

export(int,1,10) var num_of_bisects:int = 6
export(int,0,10) var max_num_of_branches:int = 5
export var is_branch:bool = false
export(int,1,10) var num_of_branch_bisects:int = 4
export(float,0.1,1) var jaggedness:float = 0.96
onready var main_bolt: Line2D = $Line2D



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		main_bolt.clear_points()
		for child in main_bolt.get_children():
			child.queue_free()
		
		create_lightning(main_bolt,position,get_global_mouse_position(),num_of_bisects)
		if is_branch:
			var num_of_branches = randi() % max_num_of_branches + 1
			for branch in num_of_branches:
				create_branch(main_bolt)
		$AnimationPlayer.play("Flash")
		

func create_lightning(bolt:Line2D, start_point:Vector2,target_pos:Vector2,num_of_bisects:int)->void:
	var tangent:Vector2 = target_pos - start_point
	bolt.clear_points()
	bolt.add_point(Vector2.ZERO)
	bolt.add_point(tangent)
	
#	print("bolt:",bolt.points)
	var persistance = 1.0

	for bisect in num_of_bisects:
		var points:Array = bolt.points
		for i in points.size() - 1:
			var start:Vector2 = points[i]
			var end:Vector2 = points[i+1]
			var mid:Vector2 = (end - start) / 2
			var vec:Vector2 = mid.normalized()
			var normal:Vector2 = Vector2(vec.y,-vec.x)
			
			var offset:float =  mid.length() * 0.6 * persistance 
			var new_point:Vector2 = start + mid + (normal * rand_range(-offset,offset))
			bolt.add_point(new_point, (i * 2) + 1)
			persistance *= jaggedness
			
#			yield(get_tree().create_timer(1),"timeout")
		


func create_branch(branch_from_bolt:Line2D)->void:
	var length:float = branch_from_bolt.points[0].distance_to(branch_from_bolt.points[-1])
	print("length:",length)

	
	var branch:Line2D = Line2D.new()
	branch.width = branch_from_bolt.width / 2
	branch.default_color = branch_from_bolt.default_color
	branch.texture = branch_from_bolt.texture
	branch.texture_mode = Line2D.LINE_TEXTURE_STRETCH 
	branch_from_bolt.add_child(branch)

	var end_index:int = randi() % (branch_from_bolt.points.size()-1) + 1 
	var end:Vector2 = branch_from_bolt.points[end_index]
#	print("index:%s,end:%s",[end_index,end])
	branch.position = end
	
	var start:Vector2 = branch_from_bolt.points[end_index - 1]
#	print("index:%s,start:",[end_index - 1,start])
	var direction:Vector2 = (end - start).normalized()
#	print("direction:",direction)
#	var scale:float = branch_from_bolt.points[0].distance_to(end) / length
#	print("index:",end_index,"scale:",scale)

	var split_end:Vector2 = direction * length / 3 
	print("split_end:",split_end)
	
#	branch.add_point(Vector2.ZERO)
#	branch.add_point(direction * 20)

	create_lightning(branch,Vector2.ZERO,split_end,num_of_branch_bisects)
#
#func random_pos_or_neg()->int:
#	var s = bool(randi() % 2)
#	if s:
#		 return 1 
#	else:
#		return -1
