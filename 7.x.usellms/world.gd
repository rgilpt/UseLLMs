extends Node2D

@onready var text_edit: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/TextEdit

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var text_edit_2: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/TextEdit2

@onready var text_edit_history: TextEdit = $PanelContainer/HBoxContainer/TextEdit
@onready var text_edit_system: TextEdit = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/TextEdit3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	text_edit_2.text = response["choices"][0]["message"]["content"]
	text_edit_history.text += "Robot: " + text_edit_2.text + "\n"


func _on_text_edit_text_changed() -> void:
	var regex = RegEx.new()
	regex.compile("\n")
	if regex.search(text_edit.text):
		chat_robot(text_edit.text, text_edit_system.text)
		text_edit_history.text += "Me: " + text_edit.text
		text_edit.text = ""
		


func chat_robot(text:String, system_content=""):
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

