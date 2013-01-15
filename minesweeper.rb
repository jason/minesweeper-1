
class Minesweeper
  NUM_ROWS = 9
  NUM_MINES = 10
  COLUMN_NAMES = ("A".."I").to_a

  def initialize
    @board = build_board
    # p @board
  end

  def build_board
    row = [nil] * NUM_ROWS
    board = []
    NUM_ROWS.times {board << row.dup}
    NUM_ROWS.times do |row|
      NUM_ROWS.times do |col|
        board[row][col] = Tile.new(0, false, false, false)
      end
    end
    board
  end

  # def build_board
  #   board = Hash.new([0, nil])
  #   cols = ("A".."I").to_a
  #   NUM_ROWS.times do |row_num|
  #     NUM_ROWS.times do |col_letter|
  #     end
  #   end
  # end



  def play
    puts "Hey! Welcome to a new game of Minesweeper!"
    setup_board
    test_board
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
    return false if @board[row][col].revealed || @board[row][col].flagged
    true
  end

  def get_move
    puts "What is your move (e.g. F1A)?"
    move = gets.chomp.upcase
    parsed_move(move)
  end

  def test_board
    @board.each do |row|
      row.each do |tile|
        if tile.mine
          print "M"
        else
          print " "
        end
        print tile.neighbor_mines
      end
      puts
    end
  end

  def calculate_neighbors
    @board.each_with_index do |row, mine_row_i|
      row.each_with_index do |mine_tile, mine_col_i|
        if mine_tile.mine
          adjust_neighbors(mine_row_i, mine_col_i)
        end
      end
    end
  end

  def adjust_neighbors(mine_row, mine_col)
    ((mine_row - 1)..(mine_row + 1)).each do |row|
      ((mine_col - 1)..(mine_col + 1)).each do |col|
        if NUM_ROWS > row && row >= 0 && NUM_ROWS > col && col >= 0
          unless row == mine_row && col == mine_col
            @board[row][col].neighbor_mines += 1
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
    if action == "F"
      @board[row][col].flagged = true
    elsif @board[row][col].mine
      return true
    else
      @board[row][col].revealed = true
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

  def parsed_move(move)
    action = move[0]
    row = (move[1].to_i - 1)
    col = COLUMN_NAMES.index(move[2])
    [action, row, col]
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

  Tile = Struct.new(:neighbor_mines, :mine, :revealed, :flagged)


end

game = Minesweeper.new
game.play

