extends Node
# for inventory
signal open_inventory()
signal close_inventory()
# for interactions
signal player_use()
signal player_collect_item(item)
# for attack
signal player_take_damage(damage)
signal player_change_damage(damage)
# for seeing pplayer
signal enemy_see_player(parent_name)
signal enemy_cant_see_player(parent_name)
