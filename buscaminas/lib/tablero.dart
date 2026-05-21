import 'dart:math';

class Cell {
  final int row;
  final int col;
  bool hasMine;
  int adjacentMines;
  bool revealed;
  bool flagged;

  Cell({required this.row, required this.col})
      : hasMine = false,
        adjacentMines = 0,
        revealed = false,
        flagged = false;
}

class Board {
  final int rows;
  final int cols;
  final int minesCount;
  late List<List<Cell>> grid;
  bool _minesPlaced = false;

  Board({required this.rows, required this.cols, required this.minesCount}) {
    _initGrid();
  }

  void _initGrid() {
    grid = List.generate(rows, (r) => List.generate(cols, (c) => Cell(row: r, col: c)));
    _minesPlaced = false;
  }

  // Place mines ensuring the first tapped cell and its neighbors are safe
  void placeMines(int safeRow, int safeCol) {
    final rand = Random();
    final positions = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // exclude safe cell and its neighbors
        if ((r - safeRow).abs() <= 1 && (c - safeCol).abs() <= 1) continue;
        positions.add(r * cols + c);
      }
    }

    positions.shuffle(rand);
    final toPlace = positions.take(minesCount).toList();
    for (final p in toPlace) {
      final r = p ~/ cols;
      final c = p % cols;
      grid[r][c].hasMine = true;
    }

    _computeAdjacentCounts();
    _minesPlaced = true;
  }

  void _computeAdjacentCounts() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int count = 0;
        for (final n in _neighbors(r, c)) {
          if (grid[n[0]][n[1]].hasMine) count++;
        }
        grid[r][c].adjacentMines = count;
      }
    }
  }

  List<List<int>> _neighbors(int r, int c) {
    final out = <List<int>>[];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr;
        final nc = c + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) out.add([nr, nc]);
      }
    }
    return out;
  }

  // Reveal a cell. Returns true if a mine was revealed (game over).
  bool reveal(int r, int c) {
    if (!_minesPlaced) placeMines(r, c);
    final cell = grid[r][c];
    if (cell.revealed || cell.flagged) return false;
    cell.revealed = true;
    if (cell.hasMine) return true;
    if (cell.adjacentMines == 0) {
      // flood fill
      final stack = <List<int>>[[r, c]];
      while (stack.isNotEmpty) {
        final cur = stack.removeLast();
        for (final n in _neighbors(cur[0], cur[1])) {
          final neigh = grid[n[0]][n[1]];
          if (!neigh.revealed && !neigh.flagged && !neigh.hasMine) {
            neigh.revealed = true;
            if (neigh.adjacentMines == 0) stack.add([n[0], n[1]]);
          }
        }
      }
    }
    return false;
  }

  void toggleFlag(int r, int c) {
    final cell = grid[r][c];
    if (cell.revealed) return;
    cell.flagged = !cell.flagged;
  }

  // Reveal all mines (used on game over)
  void revealAllMines() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.hasMine) cell.revealed = true;
      }
    }
  }

  bool checkVictory() {
    for (final row in grid) {
      for (final cell in row) {
        if (!cell.hasMine && !cell.revealed) return false;
      }
    }
    return true;
  }
}
