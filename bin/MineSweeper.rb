class MineSweeper
	include GladeGUI

	attr_accessor :rows
	attr_accessor :cols
	attr_accessor :board
	attr_accessor :mines
	attr_accessor :buttons
	attr_accessor :clicks

	def initialize (width, height)
		@rows = width
		@cols = height
		@board = []
		@mines = []
		@buttons = []
		@clicks = 0			
	end
	
	def before_show()
		topLevelWindow = @builder["window1"] 									#getting topLevel Window
		table = Gtk::Fixed.new													# Creating a Fixed Container To Place Buttons
		# creating buttons and attaching them to Fixed Container
		for i in 0..@rows-1
			tempButtons = []
			for j in 0..@cols-1
				myButton = Gtk::Button.new()
				myButton.builder_name = i.to_s + "," +j.to_s
				myButton.set_size_request 30, 30
				table.put myButton, i*30, j*30
				myButton.show
				tempButtons.push(myButton)
			end
			@buttons.push(tempButtons)
		end	
		table.add_events(Gdk::Event::BUTTON_PRESS_MASK)						#to catch right click event (it catches all button clicks)
		topLevelWindow.add(table)											#Adding Table to Top Level Window
		prepare_board
		bind_handlers														#Binding Handlers to each button
	end

	def prepare_board
		set_mines
		initialize_board
	end

	def set_mines
		no_of_mines = @cols * @rows * 0.15625
		no_of_mines = no_of_mines.to_i
				
		for i in 0..@rows-1
			boardRow=[]
			for j in 0..@cols-1
				boardRow.push (0)
			end
			@board.push(boardRow)
		end
		for i in 0..no_of_mines-1
			x = rand(@rows)
			y = rand(@cols)
			redo if @board[x][y] == -1     # to prevent repitition of mines on same index
			@board[x][y] = -1
			@mines << x
			@mines << y 
		end
	end

	def initialize_board
		for i in 0..@rows-1
			for j in 0..@cols-1
				count=0
				if @board[i][j]!=-1
					for x in i-1..i+1
						for y in j-1..j+1
							if x>=0 && y >=0 && x < @rows && y < @cols
								if @board[x][y]==-1
									count=count+1
								end
							end
						end
					end
					@board[i][j] = count
					#buttons[i][j].label = @board[i][j].to_s
				end
			end
		end
	end

	def bind_handlers
		#Binding Handlers to Each Button
		@buttons.each do |buttonArray| 
		    buttonArray.each do |button|				
				button.signal_connect("button_press_event") do |widget, event|
 					if (event.button == 3)
						if button.alignment == [0,0]
	              			button.image = nil
							button.set_alignment(0.5, 0.5)
						else
							image = Gtk::Image.new ("bin/data/media/flag.jpg")
		   					#button.add(image)
							button.image= image	
							#image.show
							button.set_alignment(0, 0)
						end	
					end				
				end	
				button.signal_connect('clicked') do |btn|
				@clicks = clicks + 1
				@builder["window1"].title = @clicks.to_s 
				index = btn.builder_name.split(',')
				x = index[0].to_i
				y = index[1].to_i							
				if @board[x][y] == -1                    #if clicked button is a mine...end game
					image = Gtk::Image.new ("bin/data/media/minered.jpg")
					@buttons[x][y].image = image	
					#image.show				
					show_mines
					
				else
					btn.label = @board[x][y].to_s
					btn.sensitive= false
					if @mines.length - 10 == @rows * @cols - @clicks			# if all mines spotted correctly, game won.. 
						show_mines 
						@builder["window1"].title = @clicks.to_s + "-You win!!"						
					end						
					uncover(x,y) if @board[x][y] == 0    #uncover sorrounding area of clicked button if no mines found in its adjacent neighbours
			                    
				end						
			end
		end	
	end
end	

	def show_mines	 
		@builder["window1"].title = @clicks.to_s + "-Game Over" 
		@builder["window1"].sensitive = false
		n = 0
		while (n < @mines.length - 1)	
		
		image = Gtk::Image.new ("bin/data/media/mine.jpg")
		@buttons[ @mines[n] ][ @mines[n+1] ].image = image
		image.show
		n = n + 2
		end
	end

	#Uncovering the clicked button's neighbours if none of them contains a mine

	def uncover (i,j)		
		x_array = [i]       #array containing x-indexes of clicked button which have 0 mines in the sorrounding
		y_array = [j]				#y-index of clicked button  "    "    "    "    "    "    "    "     "     "    "
		x_array.each_with_index do |n,index|	
			i = n
			j = y_array[index]
			for x in i-1..i+1
			 	for y in j-1..j+1
					if x>=0 && y >=0 && x < @rows && y < @cols
						next if @buttons[x][y].state == "insensitive"				# next iteration if this array index(button) has already been uncovered
						@buttons[x][y].label = @board[x][y].to_s					
						@buttons[x][y].sensitive = false
						@clicks = @clicks + 1       #click count will be updated for every array index traversed
						@builder["window1"].title = @clicks.to_s
						if @board[x][y] == 0         #if neighbours of the clicked button contain another 0 valued button,we will add that to our array
							@board[x][y] = "-"						
					  		x_array << x								#if another 0 is found in the neighbours, insert it in to uncover array
							y_array << y                # same as above, saving y-index 
						end
					end
				end
			 end 
		end
	end

	def button_clicked(widget, event)
     # which button was clicked?
     #if event.button == 1
      #   p "left click"
     #else if event.button == 2
      #   p "middle click"
      if event.button == 3
         p "right click"
		 end
	end

	#On Destroy event Handler	
	def on_window1_destroy
		destroy_window
	end
end
