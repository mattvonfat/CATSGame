extends Node2D

@export var transaction_entry_scene:PackedScene
@export var notification_scene:PackedScene

@onready var buy_transaction_list:TransactionList = $BuyTransactionList
@onready var sell_transaction_list:TransactionList = $SellTransactionList
@onready var confirm_transaction_button:Button = $ConfirmTransaction
@onready var buy_entry:TransactionEntry = $BuyEntry
@onready var sell_entry:TransactionEntry = $SellEntry

@onready var count_down_timer:Timer = $CountDownTimer
@onready var clock_timer:Timer = $ClockTimer
@onready var transaction_timer:Timer = $TransactionTimer

@onready var count_down_panel:CenterContainer = $CanvasLayer/CountdownPanel
@onready var day_label:Label = $CanvasLayer/CenterContainer2/VBoxContainer/MarginContainer2/DayLabel
@onready var count_down_label:Label = $CanvasLayer/CountdownPanel/MarginContainer/CountdownLabel
@onready var clock_label:Label = $CanvasLayer/CenterContainer2/VBoxContainer/MarginContainer4/ClockLabel

@onready var positive_rep_progress:TextureProgressBar = $CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer/MarginContainer2/PositiveRep
@onready var negative_rep_progress:TextureProgressBar = $CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer/MarginContainer/NegativeRep

@onready var notification_container:Node = $Notifications

const STARTING_HOUR:int = 9
const ENDING_HOUR:int = 17

const COMPANY_REP:int = 10
const TRADE_REP:int = 5
const FULL_REP:int = 2

const DAY_TICK_TIME:float = 1.8

var selected_buy_transaction:TransactionEntry
var selected_sell_transaction:TransactionEntry

var count_down:int

var time_hour:int
var time_minutes:int

var level_data:Dictionary

var reputation:int

func _ready():
	buy_transaction_list.entry_clicked.connect(_on_buy_entry_clicked)
	sell_transaction_list.entry_clicked.connect(_on_sell_entry_clicked)
	
	buy_transaction_list.set_list_name("BUY REQUESTS")
	sell_transaction_list.set_list_name("SELL REQUESTS")
	
	# make sure this is shown as i might forget to unhide it in editor
	count_down_panel.show()
	
	clock_timer.set_wait_time(DAY_TICK_TIME)

func start(level_number:int, current_reputation:int):
	reputation = current_reputation
	count_down = 3
	
	load_day(level_number)
	
	update_count_down_label()
	count_down_timer.start()


func load_day(level_number):
	# reset the clock
	time_hour = STARTING_HOUR
	time_minutes = 0
	
	buy_transaction_list.clear_list()
	sell_transaction_list.clear_list()
	
	buy_entry.hide()
	sell_entry.hide()
	
	confirm_transaction_button.disabled = true
	
	load_level(level_number)
	
	# update the info labels with initial values
	update_day_label(level_number)
	update_clock_label()
	update_reputation()

func start_day():
	# start game timers
	clock_timer.start()
	transaction_timer.start()


# get the level data and set timer values
func load_level(level_number:int):
	level_data = GameData.get_level_data(level_number)
	transaction_timer.set_wait_time(level_data["wait_time"])


func end_day():
	clock_timer.stop()
	transaction_timer.stop()
	GameManager.end_day(reputation)


func _on_buy_entry_clicked(entry_ref):
	if entry_ref == null:
		# means an entry has been de-selected so need to clear it
		buy_entry.hide()
		selected_buy_transaction = null
		# disable button as won't have a buy transaction
		confirm_transaction_button.disabled = true
	else:
		# new entry selected
		if selected_buy_transaction == null:
			# don't currently have a buy entry selected
			buy_entry.show()
			buy_entry.set_transaction_data(entry_ref.get_transaction_data())
			selected_buy_transaction = entry_ref
		else:
			# swapping entry
			buy_entry.set_transaction_data(entry_ref.get_transaction_data())
			selected_buy_transaction = entry_ref
		
		# see if we have a selcted sell entry and if so enable the confirm button
		if selected_sell_transaction != null:
			confirm_transaction_button.disabled = false


func _on_sell_entry_clicked(entry_ref):
	if entry_ref == null:
		# means an entry has been de-selected so need to clear it
		sell_entry.hide()
		selected_sell_transaction = null
		# disable button as won't have a sell transaction
		confirm_transaction_button.disabled = true
	else:
		# new entry selected
		if selected_sell_transaction == null:
			# don't currently have a sell entry selected
			sell_entry.show()
			sell_entry.set_transaction_data(entry_ref.get_transaction_data())
			selected_sell_transaction = entry_ref
		else:
			# swapping entry
			sell_entry.set_transaction_data(entry_ref.get_transaction_data())
			selected_sell_transaction = entry_ref
		
		# see if we have a selcted buy entry and if so enable the confirm button
		if selected_buy_transaction != null:
			confirm_transaction_button.disabled = false


func _on_confirm_transaction_pressed():
	# check that a buy and sell has been selected - should be disabled if there isn't
	if (selected_buy_transaction != null) and (selected_sell_transaction != null):
		buy_transaction_list.remove_entry(selected_buy_transaction)
		var buy_data = selected_buy_transaction.get_transaction_data()
		buy_entry.hide()
		selected_buy_transaction = null
		
		sell_transaction_list.remove_entry(selected_sell_transaction)
		var sell_data = selected_sell_transaction.get_transaction_data()
		sell_entry.hide()
		selected_sell_transaction = null
		
		confirm_transaction_button.disabled = true
		
		process_transaction(buy_data, sell_data)


func process_transaction(buy_data:Dictionary, sell_data:Dictionary):	
	if buy_data["id"] != sell_data["id"]:
		# companies didn't match
		reputation -= COMPANY_REP
		do_notification(2)
		GameManager.wrong_companies += 1
	
	else:
		# companies matched
		if (buy_data["price"] >= sell_data["price"]):
			# buy price was higher or equal to sell price
			reputation += TRADE_REP
			do_notification(1)
			GameManager.correct_price += 1
		else:
			# buy price was lower than sell price
			reputation -= TRADE_REP
			do_notification(3)
			GameManager.wrong_price += 1
	
	update_reputation()


func _on_transaction_timer_timeout():
	var random_number = GameData.rng.randf()
	
	if buy_transaction_list.is_list_full() == false:
		if random_number <= level_data["buy_chance"]:
			var transaction = GameData.generate_transaction(level_data["companies"])
			buy_transaction_list.add_entry(transaction)
	else:
		# punish for being full
		reputation -= FULL_REP
		do_notification(0)
		GameManager.lost_transactions += 1
	
	random_number = GameData.rng.randf()
	if sell_transaction_list.is_list_full() == false:
		if random_number <= level_data["sell_chance"]:
			var transaction = GameData.generate_transaction(level_data["companies"])
			sell_transaction_list.add_entry(transaction)
	else:
		# punish for being full
		reputation -= FULL_REP
		do_notification(0)
		GameManager.lost_transactions += 1
	
	update_reputation()

# updates the day clock
func _on_clock_timer_timeout():
	time_minutes += 10
	
	if time_minutes == 60:
		time_minutes = 0
		time_hour += 1
		
	update_clock_label()
	
	if time_hour == ENDING_HOUR:
		end_day()


func update_day_label(level_number:int):
	day_label.set_text("Day %s" % (level_number+1))

func update_clock_label():
	var hour_string = ("%s" % time_hour).pad_zeros(2)
	var minutes_string = ((".%s" % time_minutes).pad_decimals(2)).right(2)
	
	clock_label.set_text("%s:%s" % [hour_string, minutes_string])

func update_count_down_label(finished=false):
	if finished:
		count_down_label.set_text("Go!")
	else:
		count_down_label.set_text("%s" % count_down)

func update_reputation():
	# make sure reputation is in range of -100 to 100
	if reputation > 100:
		reputation = 100
	elif reputation < -100:
		reputation = -100
	
	# upadte progress bars
	if reputation == 0:
		positive_rep_progress.set_value(0)
		negative_rep_progress.set_value(0)
	elif reputation > 0:
		positive_rep_progress.set_value(reputation)
		negative_rep_progress.set_value(0)
	else:
		positive_rep_progress.set_value(0)
		negative_rep_progress.set_value((reputation * -1))

func _on_count_down_timer_timeout():
	count_down -= 1
	
	if count_down == -1:
		count_down_timer.stop()
		count_down_panel.hide()
		start_day()
	else:
		if count_down == 0:
			update_count_down_label(true)
		else:
			update_count_down_label(false)

func do_notification(notification_type):
	var n = notification_scene.instantiate()
	notification_container.add_child(n)
	n.finished.connect(_on_notification_finished)
	n.set_notification(notification_type)
	n.play()

func _on_notification_finished(n):
	n.queue_free()
