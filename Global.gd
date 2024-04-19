extends Node

# for interactions
signal player_use_interface()
signal player_use_object()
signal player_using_interface()
signal player_collect_item(item)
# for attack
signal player_take_damage(damage)
signal player_change_damage(damage)
# for seeing player
signal enemy_see_player(parent_name)
signal enemy_cant_see_player(parent_name)
