package edu.vtc.cis3310;

public class ScoredMove {
    Move _move;
    int _score;

    public static final int LOWER_THAN_LOW = -1000;

    public ScoredMove(Move move, int score) {
        _move = move;
        _score = score;
    }

    public ScoredMove() {
        _move = null;
        _score = LOWER_THAN_LOW;
    }

    public void setMove(Move move) {
        _move = move;
    }

    public Move getMove() {
        return _move;
    }


    public void setScore(int score) {
        _score = score;
    }
        
    public int getScore() {
        return _score;
    }

    
    @Override
    public String toString() {
        if (_move == null) {
            return "(empty move)";
        }
        return _move.toString() + "[" + _score + "]";
    }

}
