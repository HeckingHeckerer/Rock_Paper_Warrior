# MusicManager.gd
extends Node

@export var level_music = {
	"wake_up_world": preload("res://Assets/Music/Creepy Cave Music - Gemstone Caves.mp3"),
	"world_1": preload("res://Assets/Music/Dark Fantasy Tiktok Song (slowed  reverb) Yamaha - Dorian concept.mp3"), 
	"safe_forest": preload("res://Assets/Music/Dark Fantasy Tiktok Song (slowed  reverb) Yamaha - Dorian concept.mp3"), 
	"goth_vania": preload("res://Assets/Music/rpg_village02_loop.mp3")
}

var current_audio_player: AudioStreamPlayer

func play_music(level_tag: String):
	# Stop existing mu"res://Assets/Places and backgrounds/GothicVania-town-files/GothicVania-town-files/Music/rpg_village02_loop.mp3"sic
	if current_audio_player:
		current_audio_player.stop()
	
	# Create new player for this track
	current_audio_player = AudioStreamPlayer.new()
	add_child(current_audio_player)
	
	# Set and play the music
	if level_music.has(level_tag):
		current_audio_player.stream = level_music[level_tag]
		current_audio_player.play()
		
func set_volume(db: float):
	if current_audio_player:
		current_audio_player.volume_db = db
