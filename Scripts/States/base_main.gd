#base_main.gd(base class for the player states)
extends Node

class_name PlayerState

signal Player_Transitioned

var player: CharacterBody2D

func enter_state(_player):
	player = _player

func exit_state():
	pass

func handle_input(_delta):
	pass
	
func physics_update(_delta):
	pass
