# Brittany and Kriti
# W2D2
require 'yaml'

class Minesweeper
  NUM_ROWS = 16
  NUM_MINES = 40
#JW - you probably know this, but these didn't have to be fixed, since you have 2 types of games - and 
#could make it flexible for other types of boards.
# column_names has to be changed every time num_rows is changed

COLUMN_NAMES = ("A".."P").to_a

  def initialize
  #can actually build board in the play function, no?
    build_board
  end


  def play
  #jw - too friendly
    puts "Hey! Welcome to a new game of Minesweeper!"
    lost = false

    until lost
      print_board
      action, row, col = get_move
      if save?(action, row, col)
        save_game(self)
      elsif valid?(action, row, col)
        lost = evaluate_move(action, row, col)
      else
        puts "Invalid move"
      end
      break if game_won?
    end

    if lost
    #jw - too mean
      puts "Oh no, u hit a mine! loser."
    else
      puts "You won! You have successfully flagged all the mines"
    end
  end

  private

  def save?(action, row, col)
    [action, row, col].join('') == "SAV"
  end


  def build_board
    @board = empty_board
    fill_tile_neighbors
    generate_mines
    fill_tile_neighbor_mines
  end

  # Creates a new empty board of the predetermined size
  def empty_board
    Array.new(NUM_ROWS) do
      Array.new(NUM_ROWS) do
        Tile.new(0, false, false, false, [])
      end
    end
  end

  # Goes through each tile on the board and assigns its neighbors
  def fill_tile_neighbors
    @board.each_with_index do |row, row_i|
      row.each_with_index do |tile, col_i|
        find_neighbors(row_i, col_i).each do |neighbor|
          tile.neighbors << neighbor
        end
      end
    end
  end

  #goes through each spot one left/right and one up/down
  #returns array of all spots that are valid
  def find_neighbors(row, col)
    neighbors = []
    range = (0..(NUM_ROWS-1))

    ((row-1)..(row+1)).each do |neigh_row|
      ((col-1)..(col+1)).each do |neigh_col|
        if range.include?(neigh_row) && range.include?(neigh_col)
          if neigh_row != row || neigh_col != col
            neighbors << @board[neigh_row][neigh_col]
          end
        end
      end
    end
    neighbors
  end


  def valid?(action, row, col)
    return false unless action == 'R' || action =="F"
    return false unless row.match(/\d/) && COLUMN_NAMES.include?(col)
    tile = @board[(row.to_i - 1)][COLUMN_NAMES.index(col)]
    return false if tile.revealed || tile.flagged
    true
  end

  def get_move
    puts "What is your move (e.g. F1A)?"
    move = gets.chomp.upcase

    [move[0], move.match(/\d+/)[0], move[-1]]
  end

  # Uncomment the method below to see the actual board with mines for testing
  # def test_board
  #   @board.each do |row|
  #     row.each do |tile|
  #       if tile.mine
  #         print "M"
  #       else
  #         print " "
  #       end
  #       print tile.neighbor_mines
  #     end
  #     puts
  #   end
  # end

  def fill_tile_neighbor_mines
  #JW - better name?  neighbor mine count?
    @board.each_with_index do |row, row_i|
      row.each_with_index do |tile, col_i|
        if tile.mine
          tile.neighbors.each do |neighbor|
            neighbor.neighbor_mines += 1
          end
        end
      end
    end
  end



  def print_board
    puts "   #{COLUMN_NAMES.join(' ')}"
    @board.each_with_index do |row, i|
      print "#{i+1}  " if i < 9
      print "#{i+1} " if i >= 9
      row.each do |tile|
        if tile.revealed
          if tile.neighbor_mines == 0
            print "  "
          else
            print tile.neighbor_mines
            print " "
          end
        elsif tile.flagged
          print "F "
        else
          print "* "
        end
      end
      puts
    end
  end


  def evaluate_move(action, row, col)
    tile = @board[(row.to_i-1)][COLUMN_NAMES.index(col)]
    if action == "F"
      tile.flagged = true
    elsif tile.mine
      return true
    else
      tile.revealed = true
      adjust_revealed(tile)
    end
    false
  end

  def game_won?
    NUM_ROWS.times do |row|
      NUM_ROWS.times do |col|
        tile = @board[row][col]
        if tile.mine
          return false unless tile.flagged
        end
      end
    end
    true
  end

  def adjust_revealed(tile)
    if tile.neighbor_mines == 0
      tile.neighbors.each do |neighbor|
        next if neighbor.flagged
        next if neighbor.revealed
        neighbor.revealed = true
        adjust_revealed(neighbor)
      end
    end
  end

  def generate_mines
    mines = 0
    while mines < NUM_MINES
      row = rand(NUM_ROWS)
      col = rand(NUM_ROWS)
      tile = @board[row][col]
      unless tile.mine
        tile.mine = true
        mines += 1
      end
    end
  end

  Tile = Struct.new(:neighbor_mines, :mine, :revealed, :flagged, :neighbors)

end


puts "Do you want to load a saved game (y/n)?"
if gets.chomp.downcase[0] == "y"
  print "Enter the filename: "
  filename = gets.chomp
  string = File.read(filename).chomp
  game = YAML::load(string)
else
  game = Minesweeper.new
end

def save_game(game)
  print "Enter a new filename to save game in: "
  filename = gets.chomp
  File.open(filename, "w") {|f| f.puts game.to_yaml}
end

game.play




