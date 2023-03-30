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
    db = connect_to_db()
    result1 = select_from_item()
    result2 = select_from_description()
    slim(:"/index", locals:{item:result1, description:result2})
end


get("/item/my") do
    user_id = session[:id]
    if session[:id] != nil
        db = connect_to_db()
        result = select_user_item(user_id)
        slim(:"/my_item", locals:{item:result})
    else

        redirect("/login")

    end
    
end

get("/item/save") do
    user_id = session[:id]
    if session[:id] != nil
        db = connect_to_db()
        result = inner_join(user_id)
        slim(:"/saved_item", locals:{user_item_rel:result})
    else

        redirect("/login")

    end

end

get("/item") do
    slim(:new)
end

post("/item") do
    user_id = session[:id]
    db = connect_to_db()
    description_id = session[:id]
    if session[:id] != nil
        item_title = params[:item_title]
        item_description = params[:item_description]
        insert_into_description(item_description)
        result = select_last_description()
        description_id = result["id"]
        insert_into_item(item_title,user_id,description_id)
        redirect("/items/")
    else
        redirect("/login")
    end

end

post("/item/:id/delete") do
    id = params[:id].to_i
    p "id är just nu i delete:#{id}"
    db = connect_to_db()
    result = select_user_id(id)
    if result["item_id_user"].to_i == session[:id].to_i || session[:id] == 1
        delete(id)
        redirect("/items/")
    else
    flash[:notice] = "You do not have permission to delete that item!"
    redirect("/items/")
    end
end

get("/item/:id/edit") do
    id = params[:id].to_i
    db = connect_to_db()
    result = select_user_id(id)
    if result["item_id_user"].to_i == session[:id].to_i || session[:id] == 1
        result1 = select_from_item_id(id)
        description_id = result1["description_id"]
        result2 = select_from_description_id(description_id)
      
    else
        flash[:notice] = "You do not have permission to edit that item!"
    end
    slim(:"/edit", locals:{item:result1, description:result2})
end

get("/item/:id/save") do
    if session[:id] != nil
        id = params[:id].to_i
        user_id = session[:id]
        db = connect_to_db()
        result = select_from_rel(user_id)
        if  result.length > 0
            result.each do |id_hash|
                if id_hash["item_id"].to_i == id.to_i
                    flash[:notice] = "You have already saved that item!"
                    redirect("/items/")
                end
            end
            
        end
        
        insert_into_rel(user_id,id)
        redirect("/items/")
    else
        flash[:notice] = "You must login before saving an item!"
        redirect("/login")
    end

end

get("/item/:id/unsave") do
    id = params[:id]
    unsave(id)
    redirect("/item/save")
end


post("/item/:id/update") do
    id = params[:id].to_i
    name = params[:name]
    content = params[:content]
    update(id,name,content)
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
    db = connect_to_db()
    if result = login(username) != nil
        result = login(username)
        pwdigest = result["pwdigest"]
        id = result["id"]
        
    else
        flash[:notice] = "There is no regesterd account with that username! Regester account before loging in!"

        redirect("/regester/new")
       
    end

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        session[:time] = []
        session[:logins] = []
        flash[:notice] = "You have been logged in #{username}!"
        redirect("/items/")
        

    else
        flash[:notice] = "The password does not match! Try again!"
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
        if session[:time][0] - session[:time][session[:time].length-1] < 4 && session[:logins].length > 5
            sleep 10
        end
    
        redirect("/login")



    end

end