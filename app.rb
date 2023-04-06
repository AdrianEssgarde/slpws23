require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"
require "sinatra/flash"
require_relative "./model.rb"

enable :sessions

# Redirects the root path to the items index
get("/") do
    redirect("items/")
end

# Retrieves all items and their descriptions and renders the index view
#
# @see Model#select_from_item
# @see Model#select_from_description
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
        slim(:"items/my_item", locals:{item:result})
    else

        redirect("/login")

    end
    
end

# Retrieves the current user's items and renders the my_item view
#
# @see Model#select_user_item
get("/item/save") do
    user_id = session[:id]
    if session[:id] != nil
        db = connect_to_db()
        result = inner_join(user_id)
        slim(:"items/saved_item", locals:{user_item_rel:result})
    else

        redirect("/login")

    end

end

# Renders the new item view
get("/item") do
    slim(:new)
end

# Creates a new item and redirects to the items index
#
# @param [String] item_title, The title of the item
# @param [String] item_description, The description of the item
#
# @see Model#insert_into_description
# @see Model#select_last_description
# @see Model#insert_into_item
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

# Deletes an item and redirects to the items index
#
# @param [Integer] id, The id of the item to be deleted
#
# @see Model#connect
# @see Model#select_user_id
# @see Model#delete
post("/item/:id/delete") do
    id = params[:id].to_i
    result = connect(id)
    p "result är är just nu: #{result}"
    description_id = result["description_id"]
    p "Description id är just nu: #{description_id}"
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

# Retrieves an item for editing and renders the edit view
#
# @param [Integer] id, The id of the item to be edited
#
# @see Model#select_user_id
# @see Model#select_from_item_id
# @see Model#select_from_description_id
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
    slim(:"items/edit", locals:{item:result1, description:result2})
end

# Saves an item for the current user and redirects to the items index
#
# @param [Integer] id, The id of the item to be saved
#
# @see Model#select_from_rel
# @see Model#insert_into_rel
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

# Unsaves an item for the current user and redirects to the saved items view
#
# @param [Integer] id, The id of the item to be unsaved
#
# @see Model#unsave
get("/item/:id/unsave") do
    id = params[:id]
    unsave(id)
    redirect("/item/save")
end

# Updates an item and redirects to the items index
#
# @param [Integer] id, The id of the item to be updated
# @param [String] name, The new name of the item
# @param [String] content, The new content of the item
#
# @see Model#update
post("/item/:id/update") do
    id = params[:id].to_i
    name = params[:name]
    content = params[:content]
    update(id,name,content)
    redirect("/items/")
end

# Renders the register view
get("/regester/new") do
    slim(:regester)
end


# Creates a new user and redirects to '/register/new'
#
# @param [String] username, The username of the new user
# @param [String] password, The password of the new user
# @param [String] password_confirm, The password confirmation of the new user
#
# @see Model#password_ok
post("/user/new") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    
    password_ok(username,password,password_confirm)

    redirect("/regester/new")

end

# Renders the login page
#
# @see View#login
get("/login") do
    slim(:login)
end

# Logs out the user and redirects to '/login'
#
get("/logout") do
    slim(:logout)
end

# Logs out the user and redirects to '/login'
#
post("/logout") do
    session[:id] = nil
    flash[:notice] = "You have been logged out!"
    redirect("/login")
end

# Logs in the user and redirects to '/items'
#
# @param [String] username, The username of the user
# @param [String] password, The password of the user
#
# @see Model#login
# @see Model#check_password
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

    if check_password(pwdigest,password) == true
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