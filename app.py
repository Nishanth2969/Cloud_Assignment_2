from flask import Flask, render_template,request,redirect,url_for # For flask implementation
from pymongo import MongoClient # Database connector
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError # MongoDB exceptions
from bson.objectid import ObjectId # For ObjectId to work
from bson.errors import InvalidId # For catching InvalidId exception for ObjectId
import os

mongodb_host = os.environ.get('MONGO_HOST', 'localhost')
mongodb_port = int(os.environ.get('MONGO_PORT', '27017'))

try:
    client = MongoClient(mongodb_host, mongodb_port, serverSelectionTimeoutMS=5000)
    # Test connection
    client.server_info()
    db = client.camp2016
    todos = db.todo
except (ConnectionFailure, ServerSelectionTimeoutError) as e:
    print(f"Could not connect to MongoDB at {mongodb_host}:{mongodb_port}")
    print(f"Error: {e}")
    # Set placeholder values, app will show error messages
    db = None
    todos = None

app = Flask(__name__)
title = "TODO with Flask"
heading = "ToDo Reminder"
#modify=ObjectId()

def redirect_url():
	return request.args.get('next') or \
		request.referrer or \
		url_for('index')

@app.route("/list")
def lists ():
	#Display the all Tasks
	todos_l = todos.find()
	a1="active"
	return render_template('index.html',a1=a1,todos=todos_l,t=title,h=heading)

@app.route("/")
@app.route("/uncompleted")
def tasks ():
	#Display the Uncompleted Tasks
	todos_l = todos.find({"done":"no"})
	a2="active"
	return render_template('index.html',a2=a2,todos=todos_l,t=title,h=heading)


@app.route("/completed")
def completed ():
	#Display the Completed Tasks
	todos_l = todos.find({"done":"yes"})
	a3="active"
	return render_template('index.html',a3=a3,todos=todos_l,t=title,h=heading)

@app.route("/done")
def done ():
	#Done-or-not ICON
	id=request.values.get("_id")
	try:
		task=todos.find({"_id":ObjectId(id)})
		if(task[0]["done"]=="yes"):
			todos.update_one({"_id":ObjectId(id)}, {"$set": {"done":"no"}})
		else:
			todos.update_one({"_id":ObjectId(id)}, {"$set": {"done":"yes"}})
		redir=redirect_url()
		return redirect(redir)
	except InvalidId:
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Invalid task ID provided. Please use a valid task.")

#@app.route("/add")
#def add():
#	return render_template('add.html',h=heading,t=title)

@app.route("/action", methods=['POST'])
def action ():
	#Adding a Task
	name=request.values.get("name")
	desc=request.values.get("desc")
	date=request.values.get("date")
	pr=request.values.get("pr")
	
	# Validate required fields
	if not name or not name.strip():
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Task name is required. Please provide a valid task name.")
	
	if not desc or not desc.strip():
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Task description is required. Please provide a description.")
	
	if not date:
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Due date is required. Please select a date.")
	
	if not pr:
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Priority is required. Please select a priority level.")
	
	try:
		todos.insert_one({ "name":name, "desc":desc, "date":date, "pr":pr, "done":"no"})
		return redirect("/list")
	except Exception as e:
		todos_l = todos.find()
		return render_template('index.html',todos=todos_l,t=title,h=heading,error="Failed to add task. Please try again.")

@app.route("/remove")
def remove ():
	#Deleting a Task with various references
	key=request.values.get("_id")
	try:
		todos.delete_one({"_id":ObjectId(key)})
		return redirect("/")
	except InvalidId:
		todos_l = todos.find({"done":"no"})
		return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID. Cannot delete the specified task.")

@app.route("/update")
def update ():
	id=request.values.get("_id")
	try:
		task=todos.find({"_id":ObjectId(id)})
		return render_template('update.html',tasks=task,h=heading,t=title)
	except InvalidId:
		todos_l = todos.find({"done":"no"})
		return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID. Cannot update the specified task.")

@app.route("/action3", methods=['POST'])
def action3 ():
	#Updating a Task with various references
	name=request.values.get("name")
	desc=request.values.get("desc")
	date=request.values.get("date")
	pr=request.values.get("pr")
	id=request.values.get("_id")
	
	# Validate required fields
	if not name or not name.strip():
		try:
			task=todos.find({"_id":ObjectId(id)})
			return render_template('update.html',tasks=task,h=heading,t=title,error="Task name is required. Please provide a valid task name.")
		except InvalidId:
			todos_l = todos.find({"done":"no"})
			return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID.")
	
	if not desc or not desc.strip():
		try:
			task=todos.find({"_id":ObjectId(id)})
			return render_template('update.html',tasks=task,h=heading,t=title,error="Task description is required. Please provide a description.")
		except InvalidId:
			todos_l = todos.find({"done":"no"})
			return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID.")
	
	if not date:
		try:
			task=todos.find({"_id":ObjectId(id)})
			return render_template('update.html',tasks=task,h=heading,t=title,error="Due date is required. Please select a date.")
		except InvalidId:
			todos_l = todos.find({"done":"no"})
			return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID.")
	
	if not pr:
		try:
			task=todos.find({"_id":ObjectId(id)})
			return render_template('update.html',tasks=task,h=heading,t=title,error="Priority is required. Please select a priority level.")
		except InvalidId:
			todos_l = todos.find({"done":"no"})
			return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID.")
	
	try:
		todos.update_one({"_id":ObjectId(id)}, {'$set':{ "name":name, "desc":desc, "date":date, "pr":pr }})
		return redirect("/")
	except InvalidId:
		todos_l = todos.find({"done":"no"})
		return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Invalid task ID. Cannot update the specified task.")
	except Exception as e:
		todos_l = todos.find({"done":"no"})
		return render_template('index.html',a2="active",todos=todos_l,t=title,h=heading,error="Failed to update task. Please try again.")

@app.route("/search", methods=['GET'])
def search():
	#Searching a Task with various references
	key=request.values.get("key")
	refer=request.values.get("refer")
	
	if not key or not key.strip():
		todos_l = todos.find()
		return render_template('searchlist.html',todos=todos_l,t=title,h=heading,error="Search key is required. Please provide a search term.")
	
	if not refer:
		todos_l = todos.find()
		return render_template('searchlist.html',todos=todos_l,t=title,h=heading,error="Search field is required. Please select a search field.")
	
	if(refer=="id"):
		try:
			todos_l = todos.find({refer:ObjectId(key)})
			if not todos_l:
				todos_l = todos.find()
				return render_template('searchlist.html',todos=todos_l,t=title,h=heading,error="No task found with the provided ObjectId.")
		except InvalidId:
			todos_l = todos.find()
			return render_template('searchlist.html',todos=todos_l,t=title,h=heading,error="Invalid ObjectId format. Please provide a valid ObjectId.")
	else:
		todos_l = todos.find({refer:key})
		
	return render_template('searchlist.html',todos=todos_l,t=title,h=heading)

@app.route("/about")
def about():
	return render_template('credits.html',t=title,h=heading)

if __name__ == "__main__":
	env = os.environ.get('FLASK_ENV', 'development')
	port = int(os.environ.get('PORT', 5000))
	debug = False if env == 'production' else True
	app.run(host='0.0.0.0', port=port, debug=debug)