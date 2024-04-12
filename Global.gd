extends Node
# for inventory
signal open_inventory()
signal close_inventory()
# for interactions
signal player_use()
signal player_collect_item(item)
# for attack
signal player_take_damage(damage)
signal player_make_damage(damage)

