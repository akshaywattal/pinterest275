require 'sinatra'
require "json"
require 'set'


class Pinterest < Sinatra::Base
  enable :logging
  disable :show_exceptions
  #helpers Sinatra::JSON

  before do
    logger.info "Entering Request...."
    if request.request_method == "GET"
      logger.info "Get Request Received"
    end

    if request.request_method == "POST"
      body_parameters = request.body.read
      params.merge!(JSON.parse(body_parameters))
    end
  end

  # Handle Not defined Routes
  not_found do
    content_type :json
    halt 400, {:ErrorMessage => "Route not defined"}.to_json
  end

  # Error Handling - per class Standard to set Code 400
  error do
    halt 400, {:ErrorMessage => "Error in Route"}.to_json
  end

  # User Sign-Up API
  post '/users/signup' do
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Capture User Details
    user = User.new
    user.firstName = params[:firstName]
    user.lastName = params[:lastName]
    user.emailId = params[:emailId]
    user.password = params[:password]
    user._id = params[:emailId]
    user.user_id = user.emailId.hash

    # Persist to database
    user.save

    # Capture Link Details
    links = Link.new
    links.url = "/users/login/"
    links.method = "POST"

    # Creating Response Links
    halt 201, {:links => [{:url => links.url, :method => links.method}]}.to_json
  end

  # User Log-In API
  post '/users/login' do
    content_type :json
    puts "params after post params method = #{params.inspect}"

    user = User.new
    user.emailId = params[:username]
    user.password = params[:password]

    # puts User.get(params[:username])

    user1 = User.get(user.emailId)

    if user1.password = user.password
      # Creating Response Links
      links1 = Link.new
      links1.url = "/users/" +  user1.user_id + "/boards"
      links1.method = "GET"

      links2 = Link.new
      links2.url = "/users/" +  user1.user_id + "/boards"
      links2.method = "POST"

      halt 201, {:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method}]}.to_json
    else
      halt 404
    end

    end

  # User Board Creation API
  post '/users/:user_id/boards' do |user_id|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Capture User ID
    user_id = user_id

    # Capture Board Details
    board = Board.new
    board.boardName = params[:boardName]
    board.boardDesc = params[:boardDesc]
    board.category = params[:category]
    board.isPrivate = params[:isPrivate]

    # Check if record already exists
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    # Persist to database
    if !existingUser
      # Create Boards Array for new user
      boards = Boards.new
      boards.boards = Set.new
      boards._id = user_id
      boards.boards.add(board)
      puts boards.to_json
      boards.save
    else
      # Create Boards Array for existing user
      logger.info "Updated User..."
      boards = existingUser.boards
      boards.add(board)
      existingUser.boards = Set.new
      existingUser.boards = boards
      existingUser.update_attributes(boards)
    end

    # Creating Response Links
    links1 = Link.new
    links1.url = "/users/" +  user_id + "/boards/" + board.boardName
    links1.method = "GET"

    links2 = Link.new
    links2.url = "/users/" +  user_id + "/boards/" + board.boardName
    links2.method = "PUT"

    links3 = Link.new
    links3.url = "/users/" +  user_id + "/boards/" + board.boardName
    links3.method = "DELETE"

    links4 = Link.new
    links4.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins"
    links4.method = "POST"

    halt 201,{:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method},
                {:url => links3.url, :method => links3.method},{:url => links4.url, :method => links4.method}]}.to_json
  end

  # Get all User Boards
  get '/users/:user_id/boards' do |user_id|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Capture User ID
    user_id = user_id

    # Check if record already exists
    existingUser = Boards.get(user_id)

    halt 200, {Boards =>  existingUser.boards}.to_json
  end

  # Get Single Board Details
  get '/users/:user_id/boards/:board_name' do |user_id,board_name|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Capture User ID and Board Name
    user_id = user_id
    board_name = board_name

    # Get All Boards of the user
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    # Create Board Details
    board = Board.new

    existingUser.boards.each do |allBoardName|
      params.merge!(JSON.parse(allBoardName.to_json))
      if params[:boardName] == board_name
        board.boardName = params[:boardName]
        board.boardDesc = params[:boardDesc]
        board.category = params[:category]
        board.isPrivate = params[:isPrivate]
        break
      end
    end

    # Creating Response Links
    links1 = Link.new
    links1.url = "/users/" +  user_id + "/boards/" + board.boardName
    links1.method = "PUT"

    links2 = Link.new
    links2.url = "/users/" +  user_id + "/boards/" + board.boardName
    links2.method = "DELETE"

    links3 = Link.new
    links3.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins"
    links3.method = "POST"

    # Creating Final Response
    {:board => board,:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method},
                {:url => links3.url, :method => links3.method}]}.to_json
  end

  # Create Pin API
  post '/users/:user_id/boards/:board_name/pins' do |user_id,board_name|
    content_type :json
    puts "params after post params method = #{params.inspect}"
    # Board Flag
    isBoard = 0

    # Capture User ID and Board Name
    user_id = user_id
    board_name = board_name

    # Create Pin
    pin = Pin.new
    pin.pinName = params[:pinName]
    pin.image = params[:image]
    pin.description = params[:description]
    pin._id = pin.pinName.hash + pin.description.hash + rand(1000000000)

    # Get Boards
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    board = Board.new
    boards = existingUser.boards

    # Check if board exists
    if !existingUser
      halt 400, {:ErrorMessage => "Invalid User ID"}.to_json
    else
      existingUser.boards.each do |allBoardName|
        params.merge!(JSON.parse(allBoardName.to_json))
        if params[:boardName] == board_name
          # Persist Pin to Database
          pin.save

          # Fetch Board Values
          board.boardName = params[:boardName]
          board.boardDesc = params[:boardDesc]
          board.category = params[:category]
          board.isPrivate = params[:isPrivate]

          # Create Set for Pins
          pinsNew = Set.new

          # Create Iterator for Pins
          pinIterate = params[:pins]
          if pinIterate != nil
            pinIterate.each do |allPin|
            pinsNew.add(allPin)
            end
          end

          # Add new Pin
          pinsNew.add(pin._id)

          board.pins = Set.new
          board.pins = pinsNew
          boards.delete(allBoardName)
          isBoard = 1
          break
        end
      end

      if isBoard == 1
        # Set Board
        boards.add(board)
        existingUser.boards = Set.new
        existingUser.boards = boards
        existingUser.update_attributes(boards)

        # Creating Response Links
        links1 = Link.new
        links1.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins/" + pin._id
        links1.method = "GET"

        links2 = Link.new
        links2.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins/" + pin._id
        links2.method = "PUT"

        links3 = Link.new
        links3.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins/" + pin._id
        links3.method = "DELETE"

        # Creating Final Response
        halt 201, {:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method},
                                    {:url => links3.url, :method => links3.method}]}.to_json
      elsif isBoard == 0
        halt 400, {:ErrorMessage => "Board Doesn't Exist"}.to_json
        end
    end
  end

  # Get List of Pin API
  get '/users/:user_id/boards/:board_name/pins' do |user_id,board_name|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Board Flag
    isBoard = 0

    # Capture User ID and Board Name
    user_id = user_id
    board_name = board_name

    # Get Boards
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    # Create Set for Pins
    pinsCollection = Set.new

    # Check if board exists
    if !existingUser
      halt 400, {:ErrorMessage => "Invalid User ID"}.to_json
    else
      existingUser.boards.each do |allBoardName|
        params.merge!(JSON.parse(allBoardName.to_json))
        if params[:boardName] == board_name

          # Create Iterator for Pins
          pinIterate = params[:pins]
          if pinIterate != nil
            pinIterate.each do |allPin|
              String tempStore = allPin
              puts tempStore
              existingPin = Pin.get(tempStore)
              pinsCollection.add(existingPin)
            end
          end

          isBoard = 1
          break
        end
      end

      if isBoard == 1
        # Creating Final Response
        {:pins => pinsCollection}.to_json
      elsif isBoard == 0
        halt 400, {:ErrorMessage => "Board Doesn't Exist"}.to_json
      end
    end
  end

  # Get Details of Single Pin
  get '/users/:user_id/boards/:board_name/pins/:pin_id' do |user_id,board_name,pin_id|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Board Flag
    isBoard = 0

    # Capture User ID and Board Name
    user_id = user_id
    board_name = board_name
    pin_id = pin_id

    # Get Boards
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    # Check if board exists
    if !existingUser
      halt 400, {:ErrorMessage => "Invalid User ID"}.to_json
    else
      # Get Pin
      existingPin = Pin.get(pin_id)

      if(!existingPin)
        halt 400, {:ErrorMessage => "Invalid Pin ID"}.to_json
      else
        isBoard = 1
      end

      if isBoard == 1
        # Creating Response Links
        links1 = Link.new
        links1.url = "/users/" +  user_id + "/boards/" + board_name + "/pins/" + pin_id
        links1.method = "PUT"

        links2 = Link.new
        links2.url = "/users/" +  user_id + "/boards/" + board_name + "/pins/" + pin_id
        links2.method = "DELETE"

        # Creating Final Response
        halt 201, {:pin => existingPin,:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method}]}.to_json
      elsif isBoard == 0
        halt 400, {:ErrorMessage => "Board Doesn't Exist"}.to_json
        end
    end
  end

  # Delete a Pin
  delete '/users/:user_id/boards/:board_name/pins/:pin_id' do |user_id,board_name,pin_id|
    content_type :json
    puts "params after post params method = #{params.inspect}"

    # Board Flag
    isBoard = 0

    # Capture User ID and Board Name
    user_id = user_id
    board_name = board_name
    pin_id = pin_id

    # Get Boards
    existingUser = Boards.get(user_id)
    puts existingUser.to_json

    board = Board.new
    boards = existingUser.boards

    # Check if board exists
    if !existingUser
      halt 400, {:ErrorMessage => "Invalid User ID"}.to_json
    else
      # Get Pin
      existingPin = Pin.get(pin_id)

      if(!existingPin)
        halt 400, {:ErrorMessage => "Invalid Pin ID"}.to_json
      elsif
        # Delete pin
        existingUser.boards.each do |allBoardName|
          params.merge!(JSON.parse(allBoardName.to_json))
          if params[:boardName] == board_name

            # Fetch Board Values
            board.boardName = params[:boardName]
            board.boardDesc = params[:boardDesc]
            board.category = params[:category]
            board.isPrivate = params[:isPrivate]

            # Create Set for Pins
            pinsNew = Set.new

            # Create Iterator for Pins
            pinIterate = params[:pins]
            if pinIterate != nil
              pinIterate.each do |allPin|
                pinsNew.add(allPin)
              end
            end

            # Delete Pin
            pinsNew.delete(pin_id)

            board.pins = Set.new
            board.pins = pinsNew
            boards.delete(allBoardName)
            isBoard = 1
            break
          end
        end
      end

      if isBoard == 1
        # Set Board
        boards.add(board)
        existingUser.boards = Set.new
        existingUser.boards = boards
        existingUser.update_attributes(boards)

        # Creating Response Links
        links1 = Link.new
        links1.url = "/users/" +  user_id + "/boards/" + board.boardName
        links1.method = "GET"

        links2 = Link.new
        links2.url = "/users/" +  user_id + "/boards/" + board.boardName
        links2.method = "PUT"

        links3 = Link.new
        links3.url = "/users/" +  user_id + "/boards/" + board.boardName
        links3.method = "DELETE"

        links4 = Link.new
        links4.url = "/users/" +  user_id + "/boards/" + board.boardName + "/pins"
        links4.method = "POST"

        halt 200,{:links => [{:url => links1.url, :method => links1.method}, {:url => links2.url, :method => links2.method},
                             {:url => links3.url, :method => links3.method},{:url => links4.url, :method => links4.method}]}.to_json
      elsif isBoard == 0
        halt 400, {:ErrorMessage => "Board Doesn't Exist"}.to_json
      end
    end
  end

  after do
    logger.info "Leaving Request...."
  end

end