extends Node2D

@onready var cur_track = $Music
@onready var switch = false
@onready var _cur_fading = false
@onready var trackToPlay = "Music"

# Called when the node enters the scene tree for the first time.
func _ready():
	play_music($MainMenu)


func play_music(track): 
	track.play()
	cur_track = track


func stop_music(track):
	track.stop()


func fade_in_music(player: AudioStreamPlayer, duration: float = 1.0):
	var tween = get_tree().create_tween()
	# Fade from current volume to -80db (silent)
	tween.tween_property(player, "volume_db", -5, duration)



func truly_change_music():
	cur_track.volume_db = -80
	cur_track.stop()
	_cur_fading = true
	switch_music(trackToPlay, 80, 80, false, 1.0)

func switch_music(nextTrack, _fadeOut, _fadeIn, fade, duration: float = 1.0):
	if nextTrack is String:
		nextTrack = get_node(nextTrack)
	var _nextTrack = nextTrack
	var fade_in = false
	
	trackToPlay = nextTrack
	
	if fade == true: 
		var tween = get_tree().create_tween()
		tween.tween_property(cur_track, "volume_db", -80.0, duration)
		tween.tween_callback(truly_change_music)
		fade = false;
	
	if _cur_fading:
		fade_in = true
		_cur_fading = false
		play_music(_nextTrack)

	
	if fade_in:
		fade_in_music(_nextTrack, 1.0)
		
