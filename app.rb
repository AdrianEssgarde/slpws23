require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"

enable :sessions

get("/") do
    slim(:new)
end

get("/items/") do
    slim(:index)
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
