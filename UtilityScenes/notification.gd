extends Node2D

signal finished

var ns = [
	preload("res://resources/images/gui/t_full.png"),
	preload("res://resources/images/gui/g_price.png"),
	preload("res://resources/images/gui/b_comp.png"),
	preload("res://resources/images/gui/b_price.png")
]

func set_notification(n:int):
	$Sprite2D.set_texture(ns[n])

func play():
	$AnimationPlayer.play("up")

func _on_animation_player_animation_finished(anim_name):
	emit_signal("finished", self)
