package ca.uqac.inf957.chess.Aspect;

import ca.uqac.inf957.chess.Spot;
import ca.uqac.inf957.chess.agent.Player;
import ca.uqac.inf957.chess.agent.Move;
import ca.uqac.inf957.chess.piece.*;
import ca.uqac.inf957.chess.Board;

public aspect AspectMove{
	
	private Board    board;
	private Spot[][] grid;
	private Spot     spotF;
	private Spot     spotI;
	
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
				
			case "Queen":
				if (/*comportement Rook TODO*/) {
					return isBlockedByPiece("Rook",move);
					//TODO
				} 
				
		}
		
		
		
		return false;
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
			(move.xI == move.xF +1 || move.xI == move.xF-1) && ((color == 0 && move.yI == move.yF+1) || (color == 1 && move.yI+1 == move.yF)) && isOccupiedByEnemy(color,spotF)){ // Case eat
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
		//TODO Bishop
		return false;
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
		//TODO Queen
		return false;
	}
	
	
	/**
	 * Redefine the isMoveLegal(Move move) method from Rook 
	 */
	boolean around(Rook piece, Move move): target(piece) 
	 									   && args(move)
	 									   && call(boolean isMoveLegal(Move))
	{
		// Rook can only move to North, South, East or West, cannot move if a piece is between initial and final position
		int color = piece.getPlayer();
		System.out.println("Rooooooook");
		System.out.println(isPossibleToMoveColor(color,spotF));
		System.out.println(move.xI == move.xF || move.yI == move.yF);
		System.out.println(!isBlockedByPiece("Rook", move));
		
		if( (isPossibleToMoveColor(color,spotF)) &&
			(move.xI == move.xF || move.yI == move.yF) &&
			(!isBlockedByPiece("Rook", move))) {
			return true;
		} else {
			return false;
		}
	}
	
}