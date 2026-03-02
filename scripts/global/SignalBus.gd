extends Node


# Player
signal on_player_pos_changed(Vector3)


# Save
signal savegame_loaded
signal save_requested


# Camera transition
signal terminal_cam_transition_requested(Camera3D)


# Abilities
signal selected_ability_changed(StateRes)
signal ability_selector_populated(Array)
signal use_rope_requested
signal rope_state_available(bool)
signal rope_state_performed
signal exit_rope_state
signal use_bubble_requested(pos :Vector3)
signal use_glide_requested
signal glide_state_performed

signal enter_redirect_area

# Global Resources
signal abilities_setup(Array)

signal level_intro_finished

signal level_timer_updated(float)


signal fruit_picked(Node3D)
signal enter_level_portal

signal can_interact(bool)
