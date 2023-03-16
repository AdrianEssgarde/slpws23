require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"
require "sinatra/flash"
require_relative "./model.rb"

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


get("/item/my") do
    if session[:id] != nil
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item.name, user_item_rel.item_id, user.id FROM ((user_item_rel INNER JOIN item ON user_item_rel.item_id = item.id) INNER JOIN user ON user_item_rel.user_id = user.id) WHERE user_id = ?", session[:id])
        p "Här är resultatetttttt: #{result}"
        result2 = db.execute("SELECT * FROM item WHERE name = ?", )
        slim(:"/my_item", locals:{user_item_rel:result})
    else

        redirect("/login")

    end
    
end

get("/item/save") do

    if session[:id] != nil
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item.name, user_item_rel.item_id, user.id FROM ((user_item_rel INNER JOIN item ON user_item_rel.item_id = item.id) INNER JOIN user ON user_item_rel.user_id = user.id) WHERE user_id = ?", session[:id])
        p "Här är resultatetttttt: #{result}"
        result2 = db.execute("SELECT * FROM item WHERE name = ?", )
        slim(:"/saved_item", locals:{user_item_rel:result})
    else

        redirect("/login")

    end

end

get("/item") do
    slim(:new)
end

post("/item") do
    if session[:id] != nil
        item_title = params[:item_title]
        item_description = params[:item_description]
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("INSERT INTO item (name) VALUES (?)", item_title)
        db.execute("INSERT INTO description (content) VALUES (?)", item_description)
        result = db.execute("SELECT * FROM item")
        p result
        p "Resultatet är nu: #{result[result.length-1]}"
        result_last_item = result[result.length-1]
        p "Det sanna resultatet är: #{result_last_item["id"]}"
        db.execute("INSERT INTO user_item_rel (user_id,item_id) VALUES (?,?)",session[:id],result_last_item["id"])
        redirect("/items/")
    else
        redirect("/login")
    end

end

post("/item/:id/delete") do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/shop.db")
    db.execute("DELETE From item WHERE id = ?", id)
    db.execute("DELETE From description WHERE id = ?", id)
    db.execute("DELETE from user_item_rel WHERE item_id = ?", id)
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

get("/item/:id/save") do
    p "Nu körs save routen som den ska!"
    id = params[:id]
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    db.execute("INSERT INTO user_item_rel (user_id,item_id) VALUES (?,?)",session[:id],id)
    result = db.execute("SELECT * FROM user_item_rel")
    p "Här är det som är nu är tillagt i rel: #{result}"
end

get("/item/:id/unsave") do

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

get("/regester/new") do
    slim(:regester)
end



post("/user/new") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    
    
    if password.count("0-9") > 0 && password.count("a-zA-Z") > 0
    
        if password.length>=6 && password =~ /[A-Z]/

            if password == password_confirm
                id = session[:id].to_i
                password_digest = BCrypt::Password.create(password)
                regester_user(username, password_digest)
                redirect("/login")

            else
                flash[:notice] = "The password did not match. Try again!"

            end
    
        else

            flash[:notice] = "The password must include between 6 and 16 characters and at least one neds to be uppercase. Try again!"

        end

    else 
        flash[:notice] = "The password must include a number and a letter"

    end

    redirect("/regester/new")

end

get("/login") do
    slim(:login)
end

get("/logout") do
    slim(:logout)
end

post("/logout") do
    session[:id] = nil
    flash[:notice] = "You have been logged out!"
    redirect("/login")
end


post("/login") do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new("db/shop.db")
    db.results_as_hash = true
    if result = db.execute("SELECT * FROM user WHERE username = ?", username).first != nil
        result = db.execute("SELECT * FROM user WHERE username = ?", username).first
        p result
        pwdigest = result["pwdigest"]
        id = result["id"]
        flash[:notice] = "You have been logged in!"
    else

        redirect("/login")
       
    end

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        session[:time] = []
        session[:logins] = []
        redirect("/items/")
        

    else

        time1 = Time.now.to_i
        p time1
        if session[:time] == nil
            session[:time] = []
        end
        
        if session[:logins] == nil
            session[:logins] = []
        end

        session[:time] << time1
        session[:logins] << 1
        p "Tiden är nu: #{session[:time]}"
        if session[:time][0] - session[:time][session[:time].length-1] < 4 && session[:logins].length > 5
            sleep 10
        end
    
        redirect("/login")



    end

end