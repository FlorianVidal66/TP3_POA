package ca.uqac.inf957.chess.Aspect;

import ca.uqac.inf957.chess.Game;
import ca.uqac.inf957.chess.Spot;
import ca.uqac.inf957.chess.agent.Player;
import ca.uqac.inf957.chess.agent.Move;
import ca.uqac.inf957.chess.piece.*;
import ca.uqac.inf957.chess.Board;
import java.io.File;
import java.io.PrintWriter;
import java.io.FileWriter;
import java.io.IOException;

public aspect AspectMove{
	
	private Board    board;
	private Spot[][] grid;
	private Spot     spotF;
	private Spot     spotI;
	
	
	
	/**
	 *  Check if a spot is occupied by an enemy piece
	 *  
	 *  @param color The color of the current player
	 *  @param Spot  The spot where the check should be done
	 *  
	 *  @return True if the spot is occupied by the enemy else false
	 */
	private boolean isOccupiedByEnemy(int color, Spot spot) {
		if (spot.getPiece() == null) {
			return false;
		} else {
			return color != spot.getPiece().getPlayer();
		}
	}
	
	
	/**
	 * @param color color of the player
	 * @param spot spot where you want to check
	 * 
	 * @return True if the spot is occupied by the enemy or by nobody
	 */
	private boolean isPossibleToMoveColor(int color, Spot spot) {
		if (spot.getPiece() == null) {
			return true;
		} else {
			return color != spot.getPiece().getPlayer();
		}
	}
	
	
	/**
	 * Check if a movement is diagonal
	 * 
	 * @param move Movement of the piece
	 * 
	 * @return True if the movement is diagonal else false
	 */
	private boolean isMoveDiagonal(Move move) {
		// A movement is diagonal if the shift vertically and horizontally is the same in absolute value
		return (Math.abs(move.xI - move.xF) == Math.abs(move.yI - move.yF));
	}
	
	
	
	/**
	 *  Check if a piece is in between the initial and final position of the move
	 *  
	 *  @param piece The name of the moving piece
	 *  @param move  The move of the piece
	 *  
	 *  @return True if a piece is in between else false
	 */
	private boolean isBlockedByPiece(String piece, Move move) {
		switch(piece) {
		
			case "Rook":
				if (move.xI == move.xF) {
					for (int i = Math.min(move.yI, move.yF)+1; i < Math.max(move.yI, move.yF); i++) {
						if (grid[move.xI][i].isOccupied()) {
							return true;
						}
					}
				} else if(move.yI == move.yF) {
					for (int i = Math.min(move.xI, move.xF)+1; i < Math.max(move.xI, move.xF); i++) {
						if (grid[i][move.yI].isOccupied()) {
							return true;
						}
					}
				}			 
				break;
				
			case "Bishop":
				int shiftX = move.xF - move.xI;
				int shiftY = move.yF - move.yI;				
				for (int shift = 1; shift < Math.abs(shiftX); shift++) {
					if(grid[move.xI + shift*(shiftX/Math.abs(shiftX))][move.yI + shift*(shiftY/Math.abs(shiftY))].isOccupied()) {
						return true;
					}
				}		
				break;	
		}		
		return false;
	}
	
	
	
	private void writeInLog(String message) {
		File log = new File("log.txt");
		try{
			PrintWriter out = new PrintWriter(new FileWriter(log, true));
			out.println(message);
			out.close();
		}catch(IOException e){
		    System.out.println("Error in writting");
		}
	}
	
	
	/**
     * Create the log.txt file or overwrite
	 */
	void around(Game game): target(game) && call(void play())
	{
		File log = new File("log.txt");
		try{
			PrintWriter out = new PrintWriter(log);
			out.println("--------------------------------------");
			out.println("          Log of the moves");
			out.println("--------------------------------------");
			out.println("");
			out.close();
		}catch(IOException e){
		    System.out.println("Error in creating txt file");
		}
		proceed(game);
	}
	
	
	
	/**
	 * Redefine the move(Move move) method from Player 
	 */
	boolean around(Player player, Move move): target(player) 
											  && args(move) 
									  		  && call( boolean move(Move)) 
	{	
		
		int size = Board.SIZE;
		
		if (move.xI >= 0 && move.xI < size && move.xF >= 0 && move.xF < size && move.yI >= 0 && move.yI < size && move.yF >= 0 && move.yF < size) {
			this.board = player.getPlayGround();
			this.grid  = board.getGrid();	
			int color  = player.getColor();
			this.spotI = grid[move.xI][move.yI];
			this.spotF = grid[move.xF][move.yF]; 

			// Check if a piece of the player is on the initial position and if the move is valid
			if (spotI.isOccupied()) {
				Piece piece = spotI.getPiece();				
				if (color == piece.getPlayer() && piece.isMoveLegal(move)) {
					
					board.movePiece(move);
					writeInLog("  Player " + player.getColorName() + " moved " + piece.toString() + " from " + move.toString().substring(0,2) + " to " + move.toString().substring(2));
					return true;	
				} 	
			}
		} 	
		return false;

	}
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Pawn 
	 */
	boolean around(Pawn piece, Move move): target(piece) 
										   && args(move)
										   && call(boolean isMoveLegal(Move))
	{
		// Black Pawn can only move with descendant row and White with ascendant if they can't eat a piece
		int color = piece.getPlayer();
		if( ((move.xI == move.xF) && ((color == 0 && move.yI == move.yF+1) || (color == 1 && move.yI+1 == move.yF)) && !spotF.isOccupied()) || // Straight line case, can't eat
			(move.xI == move.xF +1 || move.xI == move.xF-1) && ((color == 0 && move.yI == move.yF+1) || (color == 1 && move.yI+1 == move.yF)) && isOccupiedByEnemy(color,spotF)){ // Case can eat
			return true;
		}
		return false;
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Bishop
	 */
	boolean around(Bishop piece, Move move): target(piece) 
											 && args(move)
											 && call(boolean isMoveLegal(Move))
	{
		// Rook can only move diagonally, cannot move if a piece is between initial and final position
		int color = piece.getPlayer();
		if( (isPossibleToMoveColor(color,spotF)) &&
			(isMoveDiagonal(move)) &&
			(!isBlockedByPiece("Bishop", move))) {
			return true;
		} else {
			return false;
		}
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from King 
	 */
	boolean around(King piece, Move move): target(piece) 
											 && args(move)
											 && call(boolean isMoveLegal(Move))
	{
		//TODO King
		return false;
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Knight
	 */
	boolean around(Knight piece, Move move): target(piece) 
	 									   && args(move)
	 									   && call(boolean isMoveLegal(Move))
	{
		//TODO Knight
		return false;
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Queen 
	 */
	boolean around(Queen piece, Move move): target(piece) 
	 										&& args(move)
	 										&& call(boolean isMoveLegal(Move))
	{
		int color = piece.getPlayer();
		if(isPossibleToMoveColor(color,spotF)) {
			// Queen behaves like a Rook if she moves vertically or horizontally and behave like a Bishop if she moves diagonally
			if ( ((move.xI == move.xF || move.yI == move.yF) && !isBlockedByPiece("Rook", move)) || (isMoveDiagonal(move) && !isBlockedByPiece("Bishop", move)) ) {
				return true;
			}		
		}
		return false;
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Rook 
	 */
	boolean around(Rook piece, Move move): target(piece) 
	 									   && args(move)
	 									   && call(boolean isMoveLegal(Move))
	{
		// Rook can only move vertically or horizontally, cannot move if a piece is between initial and final position
		int color = piece.getPlayer();
		if( (isPossibleToMoveColor(color,spotF)) &&
			(move.xI == move.xF || move.yI == move.yF) &&
			(!isBlockedByPiece("Rook", move))) {
			return true;
		} else {
			return false;
		}
	}
	
}