
class Minesweeper
  NUM_ROWS = 9
  NUM_MINES = 10
  COLUMN_NAMES = ("A".."I").to_a

  def initialize
    @board = build_board
  end

  def build_board
    row = [nil] * NUM_ROWS
    board = [row] * NUM_ROWS
    NUM_ROWS.times do |row|
      NUM_ROWS.times do |col|
        board[row][col] = Tile.new(0, false, false, false)
      end
    end
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

    while true
      print_board
      move = get_move
      if valid?(move)
        evaluate_move(move)
      end
    end
  end

  def get_move
    puts "What is your move (e.g. F1A)?"
    gets.chomp.upcase
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
        if row >= 0 && col >= 0
          unless row == mine_row && col == mine_col
            @board[row][col].neighbor_mines += 1
          end
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
  end

  def evaluate_move(move)
    if move[0] == "F"
      @flags << move[1..2]
  end

  def parse_move(move)
    case move[0]
    when "F"
      @flags << move[1..2]
    else
      @reveals << move[1..2]
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
      mines+=1
    end
  end

  Tile = Struct.new(:neighbor_mines, :mine, :revealed, :flagged)


end


