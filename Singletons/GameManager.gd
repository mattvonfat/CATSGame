extends Node

@onready var main_menu_scene:PackedScene = preload("res://menus/main_menu.tscn")
@onready var intro_scene:PackedScene = preload("res://GameScenes/intro_scene.tscn")
@onready var day_start_scene:PackedScene = preload("res://GameScenes/day_start_scene.tscn")
@onready var trading_scene:PackedScene = preload("res://GameScenes/trading_scene.tscn")
@onready var day_end_scene:PackedScene = preload("res://GameScenes/day_end_scene.tscn")
@onready var transition_scene:PackedScene = preload("res://menus/transition.tscn")

var game_day:int
var reputation:int

var transition_node

var wrong_companies:int
var correct_price:int
var wrong_price:int
var lost_transactions:int

# leave the splash screen
func exit_splash_screen():
	var splash_screen = get_tree().get_root().get_node("SplashScreen")
	get_tree().get_root().remove_child(splash_screen)
	splash_screen.queue_free()
	
	load_main_menu()

# loads the main menu - if options menu added then make menu_menu_node a class variable
func load_main_menu():
	var main_menu_node = main_menu_scene.instantiate()
	get_tree().get_root().add_child(main_menu_node)
	#options_menu_node = options_menu_scene.instantiate() 
	#get_tree().get_root().add_child(options_menu_node)
	#options_menu_node.hide()

# starts a new game - if options menu added then we will create a class variable
# so wont need to search for main menu
func start_new_game():
	var main_menu_node = get_tree().get_root().get_node("MainMenu")
	get_tree().get_root().remove_child(main_menu_node)
	main_menu_node.queue_free()
	
	transition_node = transition_scene.instantiate()
	
	# reset the game day and reputation
	game_day = 0
	reputation = 0
	
	load_intro()

# loads the cinematic intro which plays at the start of a new game
func load_intro():
	# load the intro node and add to tree
	var intro_node = intro_scene.instantiate()
	get_tree().get_root().add_child(intro_node)
	
	# begin the intro animation
	intro_node.begin()

# called at the end of the intro ready to go in to the first day
func end_intro():
	var intro_node = get_tree().get_root().get_node("IntroScene")
	get_tree().get_root().remove_child(intro_node)
	intro_node.queue_free()
	
	# start the first day
	start_day()


# starts a day - current day is the value of game_day which is updated at the end of the day
func start_day():
	var day_start_node = day_start_scene.instantiate()
	get_tree().get_root().add_child(day_start_node)
	
	lost_transactions = 0
	wrong_companies = 0
	wrong_price = 0
	correct_price = 0
	
	day_start_node.run_day(game_day)


func begin_trading():
	# remove the day start node
	var day_start_node = get_tree().get_root().get_node("DayStartScene")
	get_tree().get_root().remove_child(day_start_node)
	
	# add the trading scene
	var trading_node = trading_scene.instantiate()
	get_tree().get_root().add_child(trading_node)
	
	trading_node.start(game_day, reputation)


func end_day(updated_reputation:int):
	# remove trading node
	var trading_node = get_tree().get_root().get_node("TradingScene")
	get_tree().get_root().remove_child(trading_node)
	
	# add the end day scene
	var day_end_node = day_end_scene.instantiate()
	get_tree().get_root().add_child(day_end_node)
	
	reputation = updated_reputation
	
	var response_id:int
	var end_game:bool = false
	
	if reputation == 100:
		response_id = 0
	elif reputation > 20:
		response_id = 1
	elif reputation > -20:
		response_id = 2
	elif reputation > -100:
		response_id = 3
	else:
		response_id = 4
		end_game = true
	
	day_end_node.start(response_id, end_game)


# move to the next day
func next_day():
	# remove the end node
	var day_end_node = get_tree().get_root().get_node("DayEndScene")
	get_tree().get_root().remove_child(day_end_node)
	
	# update the game day ready for next day
	game_day += 1
	
	begin_transition()

func begin_transition():
	get_tree().get_root().add_child(transition_node)
	transition_node.set_day(game_day)
	transition_node.start()

func end_transition():
	# remove the end node
	get_tree().get_root().remove_child(transition_node)
	
	# start the next day
	start_day()

# player has lost the game so back to menu
func game_lost():
	var day_end_node = get_tree().get_root().get_node("DayEndScene")
	get_tree().get_root().remove_child(day_end_node)
	
	load_main_menu()
