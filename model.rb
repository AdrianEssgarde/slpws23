require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "slim"
require "bcrypt"
require "sinatra/flash"
require_relative "./app.rb"

module Model
    # Registers a new user in the database
    #
    # @param [String] username the username of the new user
    # @param [String] password_digest the password digest of the new user
    # @return [void]
    def regester_user(username, password_digest)
        db = SQLite3::Database.new("db/shop.db")
        db.execute("INSERT or IGNORE INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
    end

    # Connects to the database
    #
    # @return [SQLite3::Database] a database connection
    def connect_to_db()
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        return db
    end

    #Atempts to login a user
    #
    # @param [String] username The username 
    # @option params [String] user The user table
    #
    # @return [Hash] 
    #   *   :error [Boolean] whether an error occured
    #   *   :username [String] The username

    def login(username)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT * FROM user WHERE username = ?", username).first
        return result
    end

    #Atempts to delete a row from the item table
    #
    # @param [Integer] id The id of the item
    # @option params [String] item_id_user The user id that created the item
    # @option params [String] description_id The id of the description
    #
    # @return [nil]
    def delete(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item_id_user,description_id FROM item WHERE id=?",id).first
        description_id = result["description_id"]
        db.execute("DELETE FROM item WHERE id = ?", id)
        db.execute("DELETE FROM description WHERE id = ?", description_id)
        db.execute("DELETE FROM user_item_rel WHERE item_id = ?", id)
    end

    # Retrieves the item ID associated with the given ID
    #
    # @param [Integer] id the ID of the item to retrieve
    # @return [Hash] a hash containing the item ID associated with the given ID
    def result_item_id_user(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item_id_user FROM item WHERE id=?",id).first
    end

    # Deletes a record from the user_item_rel table
    #
    # @param [Integer] id the ID of the item to delete
    # @return [void]
    def unsave(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("DELETE FROM user_item_rel WHERE item_id=?",id)
    end

    # Retrieves item IDs associated with the given user ID from the user_item_rel table
    #
    # @param [Integer] user_id the ID of the user whose items are being retrieved
    # @return [Array<Array>] an array of arrays containing the item IDs associated with the given user ID
    def select_from_rel(user_id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("SELECT item_id FROM user_item_rel WHERE user_id=?", user_id)
    end


    # Inserts a new record into the user_item_rel table
    #
    # @param [Integer] user_id the ID of the user to associate with the item
    # @param [Integer] id the ID of the item to associate with the user
    # @return [void]
    def insert_into_rel(user_id,id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("INSERT INTO user_item_rel (user_id,item_id) VALUES (?,?)",user_id,id)
    end

    # Updates the name and content of an item and its description in the item and description tables, respectively
    #
    # @param [Integer] id the ID of the item to update
    # @param [String] name the new name of the item
    # @param [String] content the new content of the item's description
    # @return [void]
    def update(id,name,content)
        db = SQLite3::Database.new("db/shop.db")
        db.execute("UPDATE item SET name=? WHERE id =?", name, id)
        description_id = result1 = select_from_item_id(id)
        description_id = result1["description_id"]
        db.execute("UPDATE description SET content=? WHERE id=?", content, description_id)
    end


    # Inserts a new record into the description table
    #
    # @param [String] item_description the content of the item's description
    # @return [void]
    def insert_into_description(item_description)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("INSERT INTO description (content) VALUES (?)", item_description)
    end


    # Retrieves the item ID associated with the given ID from the item table
    #
    # @param [Integer] id the ID of the item to retrieve
    # @return [Hash] a hash containing the item ID associated with the given ID
    def select_user_id(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item_id_user FROM item WHERE id=?",id).first
        return result
    end


    # Retrieves all items and their properties from the item table
    #
    # @return [Array<Array>] an array of arrays containing all items and their properties   
    def select_from_item()
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result1 = db.execute("SELECT * FROM item")
        return result1
    end


    # Retrieves all descriptions and their properties from the description table
    #
    # @return [Array<Array>] an array of arrays containing all descriptions and their properties
    def select_from_description()
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result2 = db.execute("SELECT * FROM description")
        return result2
    end  


    # Retrieves all items associated with the given user ID from the item table
    #
    # @param [Integer] user_id the ID of the user whose items are being retrieved
    # @return [Array<Array>] an array of arrays containing all items associated with the given user ID
    def select_user_item(user_id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT * FROM item WHERE item_id_user=?", user_id)
        return result
    end

    # Retrieves the item associated with the given ID from the item table
    #
    # @param [Integer] id the ID of the item to retrieve
    # @return [Hash] a hash containing the item associated with the given ID
    def select_from_item_id(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result1 = db.execute("SELECT * FROM item WHERE id=?",id).first
        return result1
    end
        
    # Retrieves the description associated with the given description ID from the description table
    #
    # @param [Integer] description_id the ID of the description to retrieve
    # @return [Hash] a hash containing the description associated with the given description ID
    def select_from_description_id(description_id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result2 = db.execute("SELECT * FROM description WHERE id=?",description_id).first
        return result2
    end

    # Retrieves items and their properties, along with user ID, associated with the given user ID from the user_item_rel and item tables, respectively
    #
    # @param [Integer] user_id the ID of the user whose items are being retrieved
    # @return [Array<Array>] an array of arrays containing items and their properties, along with user ID, associated with the given user ID
    def inner_join(user_id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item.name, user_item_rel.item_id, user.id FROM ((user_item_rel INNER JOIN item ON user_item_rel.item_id = item.id) INNER JOIN user ON user_item_rel.user_id = user.id) WHERE user_id = ?", user_id)
        return result
    end

    # Inserts a new record into the item table
    #
    # @param [String] item_title the name of the item
    # @param [Integer] user_id the ID of the user to associate with the item
    # @param [Integer] description_id the ID of the description to associate with the item
    # @return [void]
    def insert_into_item(item_title,user_id,description_id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        db.execute("INSERT INTO item (name,item_id_user,description_id) VALUES (?,?,?)", item_title,user_id,description_id)
    end


    # Retrieves the ID of the last description in the description table
    #
    # @return [Array] an array containing the ID of the last description in the description table
    def select_last_description()
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT id FROM description").last
        return result
    end

    # Checks whether the given password digest matches the given password
    #
    # @param [String] pwdigest the password digest to check against the password
    # @param [String] password the password to check against the password digest
    # @return [Boolean] true if the password digest matches the password, false otherwise
    def check_password(pwdigest,password)
        if BCrypt::Password.new(pwdigest) == password
            return true
        else
            return false
        end
    end

    # Validates the given password and registers a new user with the given username and password if the password is valid
    #
    # @param [String] username the username for the new user
    # @param [String] password the password for the new user
    # @param [String] password_confirm the confirmation of the password for the new user
    # @return [String, nil] a flash message indicating whether the password is valid, or nil if the password is valid and the user is successfully registered

    def password_ok(username,password,password_confirm)
        if password.count("0-9") > 0 && password.count("a-zA-Z") > 0
        
            if password.length>=6 && password =~ /[A-Z]/

                if password == password_confirm
                    id = session[:id].to_i
                    password_digest = BCrypt::Password.create(password)
                    regester_user(username, password_digest)
                    redirect("/login")

                else
                    return flash[:notice] = "The password did not match. Try again!"

                end
        
            else

                return flash[:notice] = "The password must include between 6 and 16 characters and at least one neds to be uppercase. Try again!"

            end

        else 
            return flash[:notice] = "The password must include a number and a letter"
        end
    end


    # Retrieves the user ID and description ID associated with the given item ID from the item table
    #
    # @param [Integer] id the ID of the item whose user ID and description ID are being retrieved
    # @return [Hash] a hash containing the user ID and description ID associated with the given item ID
    def connect(id)
        db = SQLite3::Database.new("db/shop.db")
        db.results_as_hash = true
        result = db.execute("SELECT item_id_user,description_id FROM item WHERE id=?",id).first
        return result

    end

end