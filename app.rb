require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"

enable :sessions

get("/") do
    redirect("items/")
end

get("/items/") do
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result1 = db.execute("SELECT * FROM item")
    result2 = db.execute("SELECT * FROM description")
    p "All items from result: #{result1}"
    p "All items from result: #{result2}"
    slim(:"/index", locals:{item:result1, description:result2})
end

get("/item/new") do
    slim(:new)
end

post("/item/new") do
    item_title = params[:item_title]
    item_description = params[:item_description]
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("INSERT INTO item (name) VALUES (?)", item_title)
    db.execute("INSERT INTO description (content) VALUES (?)", item_description)
    redirect("/items/")

end

post("/item/:id/delete") do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/shop.db")
    db.execute("DELETE From item WHERE id = ?", id)
    db.execute("DELETE From description WHERE id = ?", id)
    redirect("/items/")
end

get("/item/:id/edit") do
    id = params[:id]
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    result1 = db.execute("SELECT * FROM item WHERE id=?",id).first
    result2 = db.execute("SELECT * FROM description WHERE id=?",id).first
    slim(:"/edit", locals:{item:result1, description:result2})

end

post("/item/:id/update") do
    id = params[:id].to_i
    name = params[:name]
    content = params[:content]
    db = SQLite3::Database.new("db/shop.db")
    db.execute("UPDATE item SET name=? WHERE id =?", name, id)
    db.execute("UPDATE description SET content=? WHERE id=?", content, id)
    redirect("/items/")
end

