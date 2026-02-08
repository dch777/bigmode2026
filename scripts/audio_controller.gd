extends AudioStreamPlayer

const save_the_city = preload("res://assets/audio/Three Red Hearts - Save the City.ogg")

func _play_music(music : AudioStream, volume = 0.0):
	playing = true

	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()

func play_menu_music():
	_play_music(save_the_city, -20.0)
	
func pause():
	playing = false

func _on_finished() -> void:
	play()
