package edu.vtc.cis3310;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;


public class Checkers implements CheckersPlayer {

    public static final int MAX_DEPTH = 15;

    // Points assigned to each successive row closer to being king'ed.
    // To be multiplied by relative row number of a piece's position
    public static final int ROW_POINT_VALUE = 10;

    private static final int[] RING_0_DATA = {1,2,3,4,8,9,16,17,24,25,29,30,31,32};
    private static final int[] RING_1_DATA = {5,6,7,12,13,20,21,26,27,28};
    private static final int[] RING_2_DATA = {10,11,15,18,22,23};
    private static final int[] RING_3_DATA = {14,19};

    private static final int RING_0_VALUE = 80;
    private static final int RING_1_VALUE = 100;
    private static final int RING_2_VALUE = 120;
    private static final int RING_3_VALUE = 140;

    // Note maximum score is achieved when all twelve pieces are kings,
    // in the best positions, as follows:
    // ring 3: 2 kings
    // ring 2: 6 kings
    // ring 1: 4 kings

    public static final int LOSING_VALUE = (-12) * RING_3_VALUE;
    public static final int WINNING_VALUE = 12 * RING_3_VALUE;

    public static final int INITIAL_ALPHA = LOSING_VALUE * 2;
    public static final int INITIAL_BETA = WINNING_VALUE * 2;

    private static Set<Integer> setForArray(int[] items) {
        int itemCount = items.length;
        HashSet<Integer> hashSet = new HashSet<Integer>(itemCount);
        for (int itemIndex=0; itemIndex<itemCount; itemIndex++) {
            int value = items[itemIndex];
            hashSet.add(new Integer(value));
        }
        return hashSet;
    }

	public Checkers(Color color) {
		_color = color;
        _ring0 = setForArray(RING_0_DATA);
        _ring1 = setForArray(RING_1_DATA);
        _ring2 = setForArray(RING_2_DATA);
        _ring3 = setForArray(RING_3_DATA);
	}

	public Color getColor() {
		return _color;
	}
	
	public Move chooseMove(Collection<Move> legalMoves, CheckersGame game) {
        int alpha = INITIAL_ALPHA;
        int beta = INITIAL_BETA;
      
        if (legalMoves.size() == 1) {
	       	for (Move move : legalMoves) {
	       		return move;
	        }
	    }
        ScoredMove scoredMove = selectMove(_color, alpha, beta, legalMoves, game.getCurrentBoard(), MAX_DEPTH, null);
		return scoredMove.getMove();
	}

    private ScoredMove selectMove(Color player, int alpha, int beta, Collection<Move> legalMoves, CheckerBoard currentBoard, int currentDepth, Move lastMove) {
        ScoredMove myBestMove = new ScoredMove(); // My best move
        ScoredMove reply = null; // Opponents best reply
        Color opponent = player.opposite();
        
        if (legalMoves.isEmpty()) {
            System.out.println("no legal moves!! currentDepth = " + currentDepth + "; alpha = " + alpha + "; beta = " + beta );
            ScoredMove finalMove = new ScoredMove(lastMove,0);
            if (player == _color) {
                finalMove.setScore(LOSING_VALUE);
            }
            else {
                finalMove.setScore(WINNING_VALUE);
            }
            return finalMove;
        }

        // We are not going to spend any more time with minimax
        // Just calculate score, and return
        if (currentDepth < 1) {
            int score = calculateScore(currentBoard, player);
            myBestMove.setScore(score);
            return myBestMove;
        }

        // We will use minimax - Initialize for lowest or upper bounds
        if (player == _color) { 
            myBestMove.setScore(alpha);
        } else {
            myBestMove.setScore(beta);
        }
        int nextDepth = currentDepth - 1;
        for (Move possibleMove : legalMoves) {
            CheckerBoard possibleBoard = currentBoard.makeMove(possibleMove);
            Collection<Move> legalReplyMoves = possibleBoard.legalMoves(opponent);
            reply = selectMove(opponent, alpha, beta, legalReplyMoves, possibleBoard, nextDepth, possibleMove);
            int replyScore = reply.getScore();
            int bestScore = myBestMove.getScore();

            if ((player == _color) && (replyScore > bestScore)) {
                myBestMove.setMove(possibleMove);
                myBestMove.setScore(replyScore);
                alpha = replyScore;
            } 
            else if ((opponent == _color) && (replyScore < bestScore)) {
                myBestMove.setMove(possibleMove);
                myBestMove.setScore(replyScore);
                beta = replyScore;
            } // updating best
        
            // the pruning
            if (alpha >= beta) {
                return myBestMove;
            }
        } // foreach
        return myBestMove;
    }
    
    // Board is configured like this:
    //
    //              R e d   S i d e
    // +----+----+----+----+----+----+----|----+
    // | 01 | ~~ | 02 | ~~ | 03 | ~~ | 04 | ~~ |
    // +----+----+----+----+----+----+----|----+
    // | ~~ | 05 | ~~ | 06 | ~~ | 07 | ~~ | 08 |
    // +----+----+----+----+----+----+----|----+
    // | 09 | ~~ | 10 | ~~ | 11 | ~~ | 12 | ~~ |
    // +----+----+----+----+----+----+----|----+
    // | ~~ | 13 | ~~ | 14 | ~~ | 15 | ~~ | 16 |
    // +----+----+----+----+----+----+----|----+
    // | 17 | ~~ | 18 | ~~ | 19 | ~~ | 20 | ~~ |
    // +----+----+----+----+----+----+----|----+
    // | ~~ | 21 | ~~ | 22 | ~~ | 23 | ~~ | 24 |
    // +----+----+----+----+----+----+----|----+
    // | 25 | ~~ | 26 | ~~ | 27 | ~~ | 28 | ~~ |
    // +----+----+----+----+----+----+----|----+
    // | ~~ | 29 | ~~ | 30 | ~~ | 31 | ~~ | 32 |
    // +----+----+----+----+----+----+----|----+
    //            W h i t e   S i d e

    // Positional scoring provides assigns a higher
    // value to regular pieces that are closer to 
    // their opposite side (they are closer to becoming
    // kings themselves).
    //
    // To capture this notion, the relative row
    // of each piece (both regular and king) is calculated.  
    // This value is in the range (0..7), where a value 
    // of 7 is only possible for a piece that is a king.
    // Accordingly, a relative row value of 0 indicates
    // the piece is on its own back row.
    //
    // King pieces are most effective as they get 
    // closer to the center of the board.  The board is
    // considered as 4 concentric rings with ring 3
    // the innermost ring, and ring 0 the outermost ring.
    // 
    // Ring 3 Positions: 14, 19
    //
    // Ring 2 Positions: 10, 11, 15, 18, 22, 23
    //
    // Ring 1 Positions: 05, 06, 07, 12, 13, 20, 21, 26, 27, 28
    //
    // Ring 0 Positions: 01, 02, 03, 04, 08, 09, 16,
    //                   17, 24, 25, 29, 30, 31, 32
    //
    // Ring 0 value of a king: 80
    // Ring 1 value of a king: 100
    // Ring 2 value of a king: 120
    // Ring 3 value of a king: 140
    // 
    private int calculatePositionalScore(Piece piece) {
        int score = 0;
        if (piece.isKing()) {
            Integer piecePosition = new Integer(piece.getPosition());
            score = kingScoreForPosition(piecePosition);
        }
        else {
            int relativeRow = relativeRowForPiece(piece);
            score = (relativeRow + 1) * ROW_POINT_VALUE;
        }
        return score;
    }

    private int kingScoreForPosition(Integer piecePosition) {
        int score = 0;
        if (_ring0.contains(piecePosition)) {
            score = RING_0_VALUE;
        }
        else if (_ring1.contains(piecePosition)) {
            score = RING_1_VALUE;
        }
        else if (_ring2.contains(piecePosition)) {
            score = RING_2_VALUE;
        }
        else if (_ring3.contains(piecePosition)) {
            score = RING_3_VALUE;
        }
        return score;
    }

    /*
    ** Determine the relative row for a piece.
    ** The row will be relative to the color of the piece
    ** where row zero is on the home row for the player owning
    ** the piece, and row seven is on the farthest away row.
    ** A red piece in position 06 is relative row 1 (the second row)
    ** A white piece in position 11 is relative row 5 (the sixth row).
    **
    ** @param piece the piece whose relative row is being requested.
    ** @return The relative row for the piece provided (range 0..7)
    */
    private int relativeRowForPiece(Piece piece) {
        int position = piece.getPosition();
        if (piece.getColor() == Color.White) {
            position = 33 - position;
        }
        int rowNumber = (position + 3) / 4; // 1 <= rowNumber <= 8
        int relativeRow = rowNumber - 1;
        return relativeRow;
    }

    private int calculateScore(CheckerBoard board, Color player) {
        int pieceCount = 32;
        int playerScore = 0;
        int opponentScore = 0;
        for (int i = 1; i <= pieceCount; i++) {
            Piece piece = board.getPiece(i);
            if (piece != null) {
                int score = calculatePositionalScore(piece);
                if (piece.getColor() == player) {
                	playerScore += score;
                }
                else {
                	opponentScore += score;
                }
            }
        }
        int score = playerScore - opponentScore;
        if (player != _color) {
            score = 0 - score;
        }
        return score;
    }
    
    public static void main(String[] args)
	{
		CheckersPlayer redPlayer = new Checkers(Color.Red);
		CheckersPlayer whitePlayer = new StupidPlayer(Color.White);
	    CheckersGame game = new CheckersGame(redPlayer,whitePlayer);
	    System.out.println(game.play());
	    System.out.println("Red required "+game.getAverageRedTime()+" seconds average");
	    System.out.println("White required "+game.getAverageWhiteTime()+" seconds average");
	}

    
    // Representation
    Color _color;
    Set<Integer> _ring0;
    Set<Integer> _ring1;
    Set<Integer> _ring2;
    Set<Integer> _ring3;
}

