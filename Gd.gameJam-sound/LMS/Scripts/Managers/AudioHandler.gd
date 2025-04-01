extends Node3D

const MAX_SFX_COUNT: int = 15
const SFX_BUS: String = "SFX"
var _SFXAudioPlayers: Array[AudioStreamPlayer] = []
var _SFXIndex: int = 0

const Ambient_BUS: String = "Ambient"
var _AmbientAudioPlayers: Dictionary = {}

const MUSIC_BUS: String = "Music"
const MUSIC_TRANSITION_TIME: float = 1.5
var _MusicAudioPlayer: AudioStreamPlayer = null
var _TransientAudioPlayer: AudioStreamPlayer = null
var _MusicFade: Tween = null

var _CurrentTrack: AudioStream = null

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_PreloadAudioPlayers()

"""
Instantiates MAX_SFX_COUNT number of AudioPlayers that are used like an object pool for SFX.
Also Instantiates 2 AudioPlayers for regular music.
"""
func _PreloadAudioPlayers() -> void:
	# Create Music AudioPlayer instance
	_MusicAudioPlayer = AudioStreamPlayer.new()
	_MusicAudioPlayer.bus = MUSIC_BUS
	_MusicAudioPlayer.name = "Music_AudioStreamPlayer"
	add_child(_MusicAudioPlayer)
	
	# Create Music Transition AudioPlayer instance
	_TransientAudioPlayer = AudioStreamPlayer.new()
	_TransientAudioPlayer.bus = MUSIC_BUS
	_TransientAudioPlayer.name = "Transient_AudioStreamPlayer"
	add_child(_TransientAudioPlayer)
	
	for index:int in range(0, MAX_SFX_COUNT):
		_SFXAudioPlayers.append(AudioStreamPlayer.new())
		_SFXAudioPlayers[index].bus = SFX_BUS
		_SFXAudioPlayers[index].name = "SFX_AudioStreamPlayer_"+str(index)
		add_child(_SFXAudioPlayers[index])

func PlaySFX(sound:AudioStream, bus:String = SFX_BUS) -> void:
	if sound == null: return
	
	# if _SFXIndex is greater than MAX_SFX_COUNT reset the _SFXIndex to 0
	if _SFXIndex >= MAX_SFX_COUNT: _SFXIndex = 0
	
	# Set the stream of the audioplayer at _SFXIndex in the SFXPlayers array to provided sound then play it
	_SFXAudioPlayers[_SFXIndex].stream = sound
	_SFXAudioPlayers[_SFXIndex].bus = bus
	_SFXAudioPlayers[_SFXIndex].play()
	_SFXIndex += 1

func PlayAmbient(sound:AudioStream, fadeInTime:float = 0.5, bus:String = Ambient_BUS) -> AudioStreamPlayer:
	if _AmbientAudioPlayers.has(sound): return _AmbientAudioPlayers[sound]
	# Create Ambient AudioPlayer instance
	var ambientAudioPlayer:AudioStreamPlayer = AudioStreamPlayer.new()
	ambientAudioPlayer.name = "Ambient_"+str(sound.get_rid())
	ambientAudioPlayer.stream = sound
	ambientAudioPlayer.bus = Ambient_BUS
	ambientAudioPlayer.volume_db = -80
	add_child(ambientAudioPlayer)
	# Add to dictionary
	_AmbientAudioPlayers[sound] = ambientAudioPlayer
	
	# Play ambient and fade it in
	ambientAudioPlayer.play()
	create_tween().tween_property(ambientAudioPlayer, "volume_db", 0, fadeInTime)
	return ambientAudioPlayer

func StopAmbient(sound:AudioStream) -> void:
	if !_AmbientAudioPlayers.has(sound): return
	_AmbientAudioPlayers[sound].stop()
	_AmbientAudioPlayers[sound].queue_free()
	_AmbientAudioPlayers.erase(sound)

func StopAllAmbient() -> void:
	pass 

func MusicIsPlaying() -> bool:
	return _CurrentTrack != null

func PlayMusic(music:AudioStream, bus:String = MUSIC_BUS) -> void:
	if !_MusicAudioPlayer || !music || music == _CurrentTrack: return
	
	# if there is no music currently playing or the transient audioplayer doesnt exist, just set the music and play it.
	if !_TransientAudioPlayer || !_CurrentTrack: 
		_MusicAudioPlayer.stream = music
		_MusicAudioPlayer.bus = bus
		_MusicAudioPlayer.volume_db = 0
		_MusicAudioPlayer.play()
		_CurrentTrack = music
		return
	
	## Otherwise, if track is already playing
	_MusicAudioPlayer.bus = bus
	_TransientAudioPlayer.bus = bus
	
	# Fade current track out - Muisc Player vol down
	if _MusicFade: _MusicFade.kill()
	_MusicFade = create_tween().set_parallel(true)
	_MusicAudioPlayer.volume_db = 0
	_MusicFade.tween_property(_MusicAudioPlayer, "volume_db", -80, MUSIC_TRANSITION_TIME)
	
	# Fade new track - Transient Player vol up
	# Set the Transient Player sound to the new track
	_TransientAudioPlayer.stream = music
	_TransientAudioPlayer.volume_db = -80
	_TransientAudioPlayer.play()
	_MusicFade.tween_property(_TransientAudioPlayer, "volume_db", 0, MUSIC_TRANSITION_TIME)
	
	# When current track is completely faded out
	_MusicFade.finished.connect(func(): 
		# Stop the Music Player
		_MusicAudioPlayer.stop()
		# Reset the Music Player volume
		_MusicAudioPlayer.volume_db = 0
		# Set the Music Player to the new track
		_MusicAudioPlayer.stream = music
		# Play the Music Player at the current position of the Transient player
		_MusicAudioPlayer.play(_TransientAudioPlayer.get_playback_position())
		# Stop the Transient Player
		_TransientAudioPlayer.stop()
		)
	
	# Set Current Music
	_CurrentTrack = music
	
	_MusicAudioPlayer.finished.connect(TrackFinished)

func TrackFinished() -> void:
	_CurrentTrack = null
