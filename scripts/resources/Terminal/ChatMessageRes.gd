extends Resource
class_name ChatMessageRes

static var employees :Dictionary = {
	'Liam' : 1628,
	'Inaya' : 0000,
	'David' : 153269,
	'Keren' : 881544,
}

@export var written_by :String
@export var content :String


func get_employee_seed() -> int:
	return employees.get(written_by)


#@export var employee_names :Array = [
#	"Aaliyah",
#	"Amandine",
#	"Aude",
#	"Charlie",
#	"Eliana",
#	"Fatoumata",
#	"Inaya",
#	"Keren",
#	"Lison",
#	"Manel",
#	"Miral",
#	"Ornella",
#	"Sélène",
#	"Valentine",
#	"Aaron",
#	"Ambroise",
#	"Ayoub",
#	"David",
#	"Ewen",
#	"Ian",
#	"John",
#	"Liam",
#	"Marvin",
#	"Nabil",
#	"Rafaël",
#	"Souleymane",
#	"William"]
