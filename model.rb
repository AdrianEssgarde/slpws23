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
    return db
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
    description_id = result1 = select_from_item_id(id)
    description_id = result1["description_id"]
    db.execute("UPDATE description SET content=? WHERE id=?", content, description_id)
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

def select_from_item()
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result1 = db.execute("SELECT * FROM item")
    return result1
end

def select_from_description()
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result2 = db.execute("SELECT * FROM description")
    return result2
end  

def select_user_item(user_id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM item WHERE item_id_user=?", user_id)
    return result
end

def select_from_item_id(id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result1 = db.execute("SELECT * FROM item WHERE id=?",id).first
    return result1
end

def select_from_description_id(description_id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result2 = db.execute("SELECT * FROM description WHERE id=?",description_id).first
    return result2
end

def inner_join(user_id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT item.name, user_item_rel.item_id, user.id FROM ((user_item_rel INNER JOIN item ON user_item_rel.item_id = item.id) INNER JOIN user ON user_item_rel.user_id = user.id) WHERE user_id = ?", user_id)
    return result
end

def insert_into_item(item_title,user_id,description_id)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("INSERT INTO item (name,item_id_user,description_id) VALUES (?,?,?)", item_title,user_id,description_id)
end

def select_last_description()
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT id FROM description").last
    return result
end
