class Menu

	include GladeGUI

	
	def on_8_clicked
		MineSweeper.new(8,8).show
	end
	
	def on_16_clicked
		MineSweeper.new(16,16).show
	end

	def on_32_clicked
		MineSweeper.new(32,32).show
	end

	def on_window1_destroy
		destroy_window
	end
end

	def check (button)
		puts button.builder_name
	end
