extends Node2D

@onready var text_edit: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/TextEdit

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var text_edit_2: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/TextEdit2

@onready var text_edit_history: TextEdit = $PanelContainer/HBoxContainer/TextEdit
@onready var text_edit_system: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/TextEdit3
@onready var panel_container: PanelContainer = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer
@onready var l_status: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/LStatus
@onready var text_edit_json: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/TextEditJSON

var json_output = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	panel_container.remove_theme_color_override("bg_color")
	panel_container.add_theme_color_override("bg_color", Color("#005f48"))
	l_status.set_text("DONE")
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	text_edit_2.text = response["choices"][0]["message"]["content"]
	text_edit_history.text += "Robot: " + text_edit_2.text + "\n"
	
	if json_output:
		var new_json = response["choices"][0]["message"]["content"].split("```")[1]
		text_edit_json.set_text(new_json)
		

func _on_text_edit_text_changed() -> void:
	var regex = RegEx.new()
	regex.compile("\n")
	if regex.search(text_edit.text):
		chat_robot(text_edit.text, text_edit_system.text)
		text_edit_history.text += "Me: " + text_edit.text
		text_edit.text = ""
		panel_container.remove_theme_color_override("bg_color")
		panel_container.add_theme_color_override("bg_color", Color("#92441d"))
		l_status.set_text("PROCESSING")
		


func chat_robot(text:String, system_content="answer as an expert"):
	if system_content == "":
		system_content = "answer as an expert"
	var body = JSON.new().stringify(
		{
			"messages": [
				{"role": "system", "content": system_content},
				{"role": "user", "content": text },
			]
		 
		})

	var error = http_request.request("http://localhost:1234/v1/chat/completions", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")



func _on_button_1_pressed() -> void:
	### Story
	text_edit_system.text = 'Create as a story teller in json format using the keys: "mainStory" , "characters", "locations", "events", "conditions", "decisions", "items", all this have integer "id", 
mainStory has "title", "summary", "body" is a list of elements that have "text", "image", "links", the links use the id to other keys. 
characters has "links" to other characters, locations, events -> links uses the "id", "type" and "relation". 
conditions have "state" boolean attribute and can be linked with characters, items and locations that sets the state. 
decisions are applied only to the player.
events have id, name, links. The events can be triggered by conditions or decisions and uses links to connect'
	json_output = true


func _on_button_2_pressed() -> void:
	### Quest
	text_edit_system.text = 'as a story teller create a quest between player and NPCs, write in json format 
use the main keys: "inputs", "locations", "items", "characters", "actions" and "rewards", write a "summary" and a "description" for the quest all have integer "id"
all links uses the "target_id", "type", "amount" and "relation" - type refers to the main keys: characters, actions, locations, rewards, items and inputs
inputs only have "id" and "value" that is can be boolean, integer or float and starts with 0
characters is a list and each have "name", "links" to other characters, locations and items, actions
items is a list and each have "name"
locations is a list and each have "name"
rewards is a list of reward objects
reward objects can be gold, items and have "amount"
the actions is list of action object
action object can be: bring , explore, attack, kill, ask, trade, discover, craft, socialize
'
	json_output = true
	
func _on_button_3_pressed() -> void:
	### Dialogue
	text_edit_system.text = 'as a story teller create a dialogue between player and NPCs, write in json format 
use the main keys: "locations", "items", "characters", "conversations" and all have integer "id"
all links uses the "target_id", "type", relation" - type refers to the main keys: characters, locations, items
items is a list and each have "name"
locations is a list and each have "name"
characters is a list and each have only "name" and "links" to other characters, locations and items
conversations is a list of dialogue that have "target_id" that is the character id that is speaking, "text", "emotion" and "response_options" is a list of objects that can be 1 and maximum of 4
response_options have an "id" and "text"
'
	json_output = true

func _on_button_4_pressed() -> void:
	### Dialogue with functions
	text_edit_system.text = 'as a story teller create a dialogue between player and NPCs, write in json format 
use the main keys: "locations", "items", "characters", "conversations" and all have integer "id"
all links uses the "target_id", "type", relation" - type refers to the main keys: characters, locations, items
items is a list and each have "name"
locations is a list and each have "name"
characters is a list and each have only "name" and "links" to other characters, locations and items
conversations is a list of dialogue that have "target_id" that is the character id that is speaking, "text", "emotion" and "response_options" is a list of objects that can be 1 and maximum of 4
response_options have an "id", "text" and "function"
function can be: "improve_relation", "disimprove_relation", "action", "reward", "decline_task", "ask_about_reward"
'
	json_output = true

func _on_button_5_pressed() -> void:
	text_edit_system.text =''
	json_output = false
