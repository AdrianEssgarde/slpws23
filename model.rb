require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"
require "sinatra/flash"
require_relative "./app.rb"

#module
def regester_user(username, password_digest)
    db = SQLite3::Database.new("db/shop.db")
    db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
end

def connect_to_db()
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
end

def login(username)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    return result
end

def delete(id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT item_id_user FROM item WHERE id=?",id).first
    db.execute("DELETE FROM item WHERE id = ?", id)
    db.execute("DELETE FROM description WHERE id = ?", id)
    db.execute("DELETE FROM user_item_rel WHERE item_id = ?", id)
end

def result_item_id_user(id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT item_id_user FROM item WHERE id=?",id).first
end

def unsave(id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("DELETE FROM user_item_rel WHERE item_id=?",id)
end

def select_from_rel(user_id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("SELECT item_id FROM user_item_rel WHERE user_id=?", user_id)
end

def insert_into_rel(user_id,id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("INSERT INTO user_item_rel (user_id,item_id) VALUES (?,?)",user_id,id)
end

def update(id,name,content)
    db = SQLite3::Database.new("db/shop.db")
    db.execute("UPDATE item SET name=? WHERE id =?", name, id)
    db.execute("UPDATE description SET content=? WHERE id=?", content, id)
end

def insert_into_description(item_description)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("INSERT INTO description (content) VALUES (?)", item_description)
end

def select_user_id(id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT item_id_user FROM item WHERE id=?",id).first
    return result
end

def inser_into_item(item_title,user_id,description_id)
end
