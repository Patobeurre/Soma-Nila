extends Area3D


@export var decreaseBounceFactor :float = 0.9
@export var minBounceSpeed :float = 20.0
@export var minYVelocityTrigger :float = 5

@export var displayDebugMesh :bool = false
@onready var debugMesh :Node3D = $MeshInstance3D


func _ready() -> void:
	debugMesh.visible = displayDebugMesh


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		var body_velocity_y :float = body.velocity.y
			
		var bounce_velocity_y :float = -body_velocity_y * decreaseBounceFactor
		bounce_velocity_y = max(bounce_velocity_y, minBounceSpeed)
		
		var bounce_force = Vector3(0, -body_velocity_y + bounce_velocity_y, 0)
		
		body.applyExternalForce(bounce_force)
