extends Node2D

class_name TransactionList

signal entry_clicked(entry_ref)

enum { LEFT_COLUMN=0, RIGHT_COLUMN }

@export var transaction_entry_scene:PackedScene

@onready var transaction_entry_collection:Node = $TransactionEntries


var column_arrays:Array = [[],[]]

var selected_entry:TransactionEntry

func add_entry(transaction_data:Dictionary):
	var entry:TransactionEntry = transaction_entry_scene.instantiate()
	transaction_entry_collection.add_child(entry)
	
	entry.entry_clicked.connect(_on_transaction_entry_clicked)
	entry.set_transaction_data(transaction_data)
	
	if column_arrays[LEFT_COLUMN].size() <= column_arrays[RIGHT_COLUMN].size():
		entry.position.x = position.x + 69
		entry.position.y = 85 + (column_arrays[LEFT_COLUMN].size() * 54)
		
		entry.set_column(LEFT_COLUMN)
		entry.set_index(column_arrays[LEFT_COLUMN].size())
		
		column_arrays[LEFT_COLUMN].append(entry)
	else:
		entry.position.x = position.x + 199
		entry.position.y = 85 + (column_arrays[RIGHT_COLUMN].size() * 54)
		
		entry.set_column(RIGHT_COLUMN)
		entry.set_index(column_arrays[RIGHT_COLUMN].size())
		
		column_arrays[RIGHT_COLUMN].append(entry)

func _on_transaction_entry_clicked(column, index):
	if selected_entry == column_arrays[column][index]:
		# have clicked the entry that was already selected so need to deselect it
		selected_entry.enable_entry()
		selected_entry = null
	else:
		if selected_entry != null:
			# already had a selected entry so deselect that first
			selected_entry.enable_entry()
			
		selected_entry = column_arrays[column][index]
		selected_entry.disable_entry()
	
	emit_signal("entry_clicked", selected_entry)

func remove_entry(entry_ref):
	var index:int = column_arrays[0].find(entry_ref)
	
	var column:int
	if index != -1:
		# in first column
		column = 0
	else:
		# in second column
		index = column_arrays[1].find(entry_ref)
		if index == -1:
			# we have a problem
			print("ERROR ENTRY DOESN'T EXIST")
			return
		column = 1
	
	#clear the entry
	entry_ref.hide()
	entry_ref.queue_free()
	column_arrays[column].remove_at(index)
# move other entries up
	for i in range(index, column_arrays[column].size()):
		column_arrays[column][i].position.y -= 54
		column_arrays[column][i].set_index(i)

# returns true if both arrays contain 10 elements
func is_list_full() -> bool:
	if (column_arrays[LEFT_COLUMN].size() == 10) and (column_arrays[RIGHT_COLUMN].size() == 10):
		return true
	
	return false

func clear_list():
	column_arrays[0].clear()
	column_arrays[1].clear()
	
	for entry in transaction_entry_collection.get_children():
		entry.queue_free()

func set_list_name(new_name:String):
	$BackgroundSprite/VBoxConatiner/CenterContainer/Label.set_text(new_name)
