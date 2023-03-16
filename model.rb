require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"
require "sinatra/flash"

#module
def regester_user(username, password_digest)
    db = SQLite3::Database.new("db/shop.db")
    db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
end

def connect_to_db()
    db = SQLite3::Database.new("db/shop.db")
end

def inner_join(id)
    result = db.execute("SELECT item.name, user_item_rel.item_id, user.id FROM ((user_item_rel INNER JOIN item ON user_item_rel.item_id = item.id) INNER JOIN user ON user_item_rel.user_id = user.id) WHERE user_id = ?", id)
end

def login(username)
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
end