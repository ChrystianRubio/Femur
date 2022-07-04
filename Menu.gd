extends Control



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_enter"):
		_on_ButtonLogin_button_down()


# for set name in directory
var loginUserDirectory = ""


#for set name in file
var loginUserFile = ""


#for open user directory 
var verifyLoginUser = Directory.new()


# login
func _on_ButtonLogin_button_down():

	loginUserFile = str($VBoxContainer/LineUsername.text + ".json")
	loginUserDirectory = $VBoxContainer/LineUsername.text
	verifyLoginUser = Directory.new()


	# verify if loginUserFile is null or not
	if loginUserFile != ".json": 

		verifyLoginUser = File.new()
		verifyLoginUser.open("db/userCurrent.json", File.WRITE) 
		verifyLoginUser.store_line(to_json({"userCurrent": loginUserDirectory}))
		verifyLoginUser.close()
		get_tree().change_scene("Fibula.tscn")
		verifyLoginUser = Directory.new()

		if verifyLoginUser.dir_exists("users/" + loginUserDirectory): 
			# create a file de name current
			verifyLoginUser = File.new()
			verifyLoginUser.open("db/userCurrent.json", File.WRITE) 
			verifyLoginUser.store_line(to_json({"userCurrent": loginUserDirectory}))
			verifyLoginUser.close()
			get_tree().change_scene("Fibula.tscn")
		else:
			$VBoxContainer/ButtonLogin.text = "username not found"
			$StandantTextLogin.start()


	else: 
		$VBoxContainer/ButtonLogin.text = "please enter correctly your username"
		$StandantTextLogin.start()



func _on_ButtonCreate_Account_button_down():
	verifyLoginUser = Directory.new()
	loginUserFile = str($VBoxContainer/LineUsername.text + ".json")
	loginUserDirectory = $VBoxContainer/LineUsername.text

	if loginUserFile != ".json":

		if verifyLoginUser.dir_exists("users/" + loginUserDirectory):
			$VBoxContainer/ButtonCreate_Account.text = "account exist"
		else: # verify if account dont exist to create
			verifyLoginUser.open("users/")
			verifyLoginUser.make_dir(loginUserDirectory)
			$VBoxContainer/ButtonCreate_Account.text = "account created"

	else:
		$VBoxContainer/ButtonCreate_Account.text = "please type correctly your username"
		$StandartTextCreated_Account.start()


func _on_ButtonExit_button_down():
	get_tree().quit()


func _on_StandantTextLogin_timeout():
	$VBoxContainer/ButtonLogin.text = "login"


func _on_StandartTextCreated_Account_timeout():
	$VBoxContainer/ButtonCreate_Account.text = "create account"
