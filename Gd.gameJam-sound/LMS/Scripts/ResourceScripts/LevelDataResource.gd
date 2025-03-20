extends Resource
class_name LevelData

@export var PackedLevel: PackedScene

@export_category("Settings")
@export var LevelName: String = "Level"
@export var TimeLimit: float = 15
@export var SkyBox: Texture2D

@export_category("Data")
@export var Completed: bool = false
@export var PersonalCompleteTime: float = -1
