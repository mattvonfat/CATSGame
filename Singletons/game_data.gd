extends Node

var companies = [
	{ "name": "Mousazon", "min_price": 10, "max_price": 15, "logo": preload("res://resources/images/logos/mousazon.png") },
	{ "name": "Furrari", "min_price": 6, "max_price": 10, "logo": preload("res://resources/images/logos/furrari.png") },
	{ "name": "Meowcrosoft", "min_price": 7, "max_price": 9, "logo": preload("res://resources/images/logos/meowcrosoft.png") },
	{ "name": "Tabby Express", "min_price": 22, "max_price": 28, "logo": preload("res://resources/images/logos/tabex.png") },
	{ "name": "Tabby Bank", "min_price": 233, "max_price": 239, "logo": preload("res://resources/images/logos/tabbybank.png") },
	{ "name": "Purrd", "min_price": 76, "max_price": 79, "logo": preload("res://resources/images/logos/Puurd.png") } ]

var level_data = [
	{ 	# level 0
		"companies": [0],
		"wait_time": 1.1,
		"buy_chance": 0.3,
		"sell_chance": 0.3,
		"start_text": "For the first day we're just going to trial the system with a single stock and see how it goes. If it only makes transactions where the buy price is higher than the sale price then we'll feel comfortable continuing with more substantial testing."
	},
	{ 	# level 1
		"companies": [0, 1],
		"wait_time": 1.1,
		"buy_chance": 0.3,
		"sell_chance": 0.3,
		"start_text": "We've decided to expand the testing of your system to handle multiple stocks. We need to ensure that it only makes transactions between stocks of the same company before we expand it operation."
	},
	{ 	# level 2
		"companies": [0, 1, 2],
		"wait_time": 1.1,
		"buy_chance": 0.4,
		"sell_chance": 0.4,
		"start_text": "Everything seems to be working well so far so we're happy to open up the CATS trial to more comapnies today."
	},
	{ 	# level 3
		"companies": [0, 1, 2],
		"wait_time": 0.8,
		"buy_chance": 0.5,
		"sell_chance": 0.5,
		"start_text": "The higher ups have expressed concerns about the number of orders that CATS can store, the worry is that if it can't match orders quickly enough then it will prevent new orders being submitted. We have previously only allowed a handful of traders access to the system and today we will be opening it up to a wider number of users."
	},
	{ 	# level 4
		"companies": [0, 1, 2, 3],
		"wait_time": 1.0,
		"buy_chance": 0.9,
		"sell_chance": 0.9,
		"start_text": "With the continued sucess of CATS we are increasing the number of companies again and opeing it up to more traders."
	},
	{ 	# level 5
		"companies": [0, 1, 2, 3, 4],
		"wait_time": 1.0,
		"buy_chance": 0.9,
		"sell_chance": 0.9,
		"start_text": "As the system is handling the increase in trades we will be giving it a new stock to manage."
	},
	{ 	# level 6
		"companies": [0, 1, 2, 3, 4, 5],
		"wait_time": 0.8,
		"buy_chance": 0.9,
		"sell_chance": 0.9,
		"start_text": "The board has agreed that the tests so far have been very successful so we are happy to report that we will be moving out of the testing phase and opening it up to all stocks and traders. Good job!"
	},
	{	# level infinity
		"companies": [0, 1, 2, 3, 4, 5],
		"wait_time": 0.5,
		"buy_chance": 0.8,
		"sell_chance": 0.8,
		"start_text": "The system is working to expectations. We're looking forward to another successful day."
	} ]

var rng = RandomNumberGenerator.new()

func generate_transaction(company_list):
	var company_id = company_list[rng.randi_range(0, company_list.size()-1)]
	
	var price_number:float = rng.randi_range(companies[company_id]["min_price"], companies[company_id]["max_price"])
	var price_decimal:float = rng.randi_range(0,99)
	
	var combined_price = price_number + (price_decimal * 0.01)
	
	var result = { "id": company_id, "price": combined_price }
	
	return result

func get_level_data(level_id:int):
	# if level_id is lower than the number of levels then return the data for that level
	# otherwise we return the data for the final level so game can continue forever
	if level_id < level_data.size():
		return level_data[level_id]
	
	return level_data[level_data.size()-1]

func get_logo(company_id) -> Texture2D:
	return companies[company_id]["logo"]

func get_start_text(level_id:int):
	# if level_id is lower than the number of levels then return the data for that level
	# otherwise we return the data for the final level so game can continue forever
	if level_id < level_data.size():
		return level_data[level_id]["start_text"]
	
	return level_data[level_data.size()-1]["start_text"]


func get_companies(level_id:int):
	return level_data[level_id]["companies"]

func get_company_name(company_id:int):
	return companies[company_id]["name"]
