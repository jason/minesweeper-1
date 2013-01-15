# Brittany and Kriti
# W2D2


class Minesweeper
  NUM_ROWS = 9
  NUM_MINES = 10
  COLUMN_NAMES = ("A".."I").to_a

  def initialize
    @board = build_board
  end


  def build_board
    row = [nil] * NUM_ROWS
    @board = []
    NUM_ROWS.times {@board << row.dup}
    NUM_ROWS.times do |row|
      NUM_ROWS.times do |col|
        @board[row][col] = Tile.new(0, false, false, false, [])
      end
    end
    fill_in_neighbors
    @board
  end

  def fill_in_neighbors
    @board.each_with_index do |row, row_i|
      row.each_with_index do |tile, col_i|
        find_neighbors(row_i, col_i).each {|neighbor| tile.neighbors << neighbor}
      end
    end
  end

  def find_neighbors(row, col)
    neighbors = []
    ((row-1)..(row+1)).each do |neigh_row|
      ((col-1)..(col+1)).each do |neigh_col|
        if NUM_ROWS > neigh_row && neigh_row >= 0 
          if NUM_ROWS > neigh_col && neigh_col >= 0
            if neigh_row != row || neigh_col != col
              neighbors << @board[neigh_row][neigh_col]
            end
          end
        end
      end
    end
    neighbors
  end


  def play
    puts "Hey! Welcome to a new game of Minesweeper!"
    setup_board
    # Uncomment line below to see the actual board with mines for testing
    #test_board
    lost = false

    until lost
      print_board
      action, row, col = get_move
      if valid?(action, row, col)
        lost = evaluate_move(action, row, col)
      else
        puts "Invalid move"
      end
      break if game_won?
    end

    if lost
      puts "Oh no, u hit a mine! loser."
    else
      puts "You won! You have successfully flagged all the mines"
    end
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
    [move[0], move[1], move[2]]
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

  def calculate_neighbors
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




  def setup_board
    generate_mines
    calculate_neighbors
  end


  def print_board
    puts "  #{COLUMN_NAMES.join(' ')}"
    @board.each_with_index do |row, i|
      print "#{i+1} "
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

# filename = ARGV[0]
# if filename
#   board = File.readlines(filename)
game = Minesweeper.new
game.play

