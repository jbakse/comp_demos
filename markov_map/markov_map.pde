import java.util.LinkedList;

int TILE_SIZE = 16;
int SCREEN_WIDTH = 1024;
int SCREEN_HEIGHT = 768;
int TILE_COLUMNS = SCREEN_WIDTH / TILE_SIZE;
int TILE_ROWS = SCREEN_HEIGHT / TILE_SIZE;

int foreColor = 1;

class Tile
{
	int id;
	boolean manual;
}

Tile[][] tiles = new Tile[TILE_COLUMNS][TILE_ROWS];


void setup()
{
	size(1024,768);
	for (int row = 0; row < TILE_ROWS; row++){
		for (int col = 0; col < TILE_COLUMNS; col++){
			tiles[col][row] = new Tile();
			tiles[col][row].id = 0;
			tiles[col][row].manual = false;
		}
	}

}

void draw()
{
	

	background(40);
	for (int row = 0; row < TILE_ROWS; row++){
		for (int col = 0; col < TILE_COLUMNS; col++){
			int x = col * TILE_SIZE;
			int y = row * TILE_SIZE;
			switch(tiles[col][row].id) {
				case 0:
				fill(50,0,0);
				break;

				case 1:
				fill(0, 200, 0);
				break;

				case 2:
				fill(0, 0, 255);
				break;

				case 3:
				fill(150, 150, 150);
			}

			noStroke();
			if (tiles[col][row].manual){
				stroke(0, 255, 0);
			}
			rect(x, y, TILE_SIZE - 1, TILE_SIZE - 1);
		}
	}
}


void mousePressed()
{
	int col = mouseX / TILE_SIZE;
	int row = mouseY / TILE_SIZE;
	tiles[col][row].id = foreColor;
	tiles[col][row].manual = (foreColor > 0);
	recalcMap();
}

void keyPressed() {
	if (key == '1') {
		foreColor = 1;
	}

	if (key == '2') {
		foreColor = 2;
	}

	if (key == '3') {
		foreColor = 3;
	}

	if (key == ' ') {
		foreColor = 0;
	}
}


void recalcMap()
{
	// randomSeed(1);

	//blank autogens
	for (int row = 0; row < TILE_ROWS; row++){
		for (int col = 0; col < TILE_COLUMNS; col++){
			if (tiles[col][row].manual == false) {
				tiles[col][row].id = 0;
			}
		}
	}

	//calc seed
	HashMap<Integer, ArrayList<Integer>> fingerPrintsIDs = new HashMap<Integer, ArrayList<Integer>>();

	for (int row = 0; row < TILE_ROWS; row++){
		for (int col = 0; col < TILE_COLUMNS; col++){
			if (tiles[col][row].manual == false) continue;
			int f = getFingerprint(col, row);
			if (f != 0) {
				ArrayList<Integer> ids = fingerPrintsIDs.get(f);
				if (ids == null) {
					ArrayList<Integer> newIds = new ArrayList<Integer>();
					newIds.add(tiles[col][row].id);
					fingerPrintsIDs.put(f, newIds);
				} else {
					ids.add(tiles[col][row].id);
				}
			}
		}
	}


	for (int row = 0; row < TILE_ROWS; row++){
		for (int col = 0; col < TILE_COLUMNS; col++){
			//calculate the tile id
			int calculatedID = 1;//(int)random(1,4);
			
			int f = getFingerprint(col, row);
			if (f != 0) {
				ArrayList<Integer> ids = new ArrayList<Integer>();

				//find a wildcard matched fingerprint
				for (Integer fingerPrint : fingerPrintsIDs.keySet()) {
					if (closeEnough(f, fingerPrint)) {
						ids.addAll(fingerPrintsIDs.get(fingerPrint));
					}
				}

				if (f == 1000) {
					println(f + " " + ids);
				}

				//fingerPrintsIDs.get(f);
				
				if (ids.size() > 0) {
					calculatedID = ids.get((int)random(0, ids.size()));
				}
			}


			//apply the calculated id only if not manually set
			if (tiles[col][row].manual == false) {
				tiles[col][row].id = calculatedID;
			}
		}
	}
}

boolean closeEnough(int needle, int haystack){
	int tempNeedle = needle;
	int tempHaystack = haystack;
	LinkedList<Integer> needleDigits = new LinkedList<Integer>();
	LinkedList<Integer> haystackDigits = new LinkedList<Integer>();
	while (tempNeedle > 0) {
	    needleDigits.push( tempNeedle % 10 );
	    tempNeedle = tempNeedle / 10;
	}
	while (needleDigits.size() < 8) {
		 needleDigits.push( 0 );
	}

	while (tempHaystack > 0) {
	    haystackDigits.push( tempHaystack % 10 );
	    tempHaystack = tempHaystack / 10;
	}
	while (haystackDigits.size() < 8) {
		 haystackDigits.push( 0 );
	}



	while (needleDigits.size() > 0) {
		int needleDigit = needleDigits.removeFirst();
		int haystackDigit = haystackDigits.removeFirst();
		if (needleDigit > 0 && needleDigit != haystackDigit) {
			return false;
		}
	}
	return true;
}

int getFingerprint(int col, int row) {
	//calculates fingerprint as 8 digit number. each digit is the id of a neighbor starting at top clockwise
	if (col <= 0 || col >= TILE_COLUMNS - 1) return 0;
	if (row <= 0 || row >= TILE_ROWS - 1) return 0;

	return 
	tiles[col + 0][row - 1].id * 10000000 +
	tiles[col + 1][row - 1].id * 1000000 +
	tiles[col + 1][row + 0].id * 100000 +
	tiles[col + 1][row + 1].id * 10000 +
	tiles[col + 0][row + 1].id * 1000 +
	tiles[col - 1][row + 1].id * 100 +
	tiles[col - 1][row + 0].id * 10 +
	tiles[col - 1][row - 1].id * 1;
}
