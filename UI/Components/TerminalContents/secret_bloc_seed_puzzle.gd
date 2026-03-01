extends VBoxContainer


const WRONG_CHARACTER = "X"
var currentSeed :int = -1

@onready var current_seed_label :RichTextLabel = $GridContainer/CurrentBlocSeedLabel
@onready var secret_seed_label :RichTextLabel = $GridContainer/SecretBlocSeedLabel


func _ready() -> void:
	currentSeed = Global.main_level_res.seed
	if currentSeed != -1:
		update_seed_labels()


func update_seed_labels() -> void:
	var secretSeedStr :String = str(Global.SECRET_LEVEL_SEED)
	var currentSeedStr :String = str(currentSeed)

	var maxLength :int = max(secretSeedStr.length(), currentSeedStr.length())

	currentSeedStr = currentSeedStr.pad_zeros(maxLength)
	secretSeedStr = secretSeedStr.pad_zeros(maxLength)

	var matchingSeedStr = ""

	for i in range(maxLength):
		if secretSeedStr[i] == "0":
			matchingSeedStr += " "
		elif currentSeedStr[i] == secretSeedStr[i]:
			matchingSeedStr += secretSeedStr[i]
		else:
			matchingSeedStr += WRONG_CHARACTER

	current_seed_label.text = currentSeedStr
	secret_seed_label.text = matchingSeedStr
