class_name Behavior

extends Node


var notice_area: Area2D
var noticed_player := false
var speed := 5000.0
var enemy : Enemy


func body_endered_notice_area(body: Node2D) -> void:
	if body is Player:
		noticed_player = true


func body_exited_notice_area(body: Node2D) -> void:
	if body is Player:
		noticed_player = false
