# x86 Assembly Programming Projects

## Overview

This repository contains projects from the Microcomputer Lab course, showcasing x86 assembly language programming skills ranging from arithmetic algorithms to interactive game development.

## Course Information

- **Course:** Microcomputer Lab
- **Language:** x86 Assembly (MASM)
- **Platform:** DOS/x86 architecture

## Projects

### 1. Midterm Project: GCD & LCM Calculator

A command-line calculator that computes the Greatest Common Divisor (GCD) and Least Common Multiple (LCM) of two numbers.

**Features:**
- Accepts two 2-digit decimal numbers as input
- Implements Euclidean algorithm for GCD calculation
- Computes LCM using the formula: `LCM(a,b) = (a × b) / GCD(a,b)`
- Input validation with error handling
- ESC key to exit program

**Technical Highlights:**
- BCD to hexadecimal conversion for calculations
- Hexadecimal to BCD conversion for output display
- DOS interrupts for I/O operations (INT 21h)
- Efficient modulo operations using DIV instruction

**Usage:**
```
Enter first number: 24
Enter second number: 36
GCD is 12
LCM is 72
```

---

### 2. Final Project: Pong Game

**Location:** `/final/`

A single-player Pong game where you compete against an AI opponent with three difficulty levels.

**Features:**
- Single-player vs AI gameplay
- Three difficulty modes (Easy, Medium, Hard)
- Main menu with difficulty selection
- Real-time ball physics and collision detection
- Dynamic color-changing ball (changes with each point scored)
- Score tracking (first to 10 points wins)
- Game over screen with restart option

**Technical Highlights:**
- VGA graphics programming (Mode 13h - 320×200, 256 colors)
- Game state management (menu system, active game, game over)
- System time-based game loop for consistent frame timing (INT 21h, AH=2Ch)
- AABB (Axis-Aligned Bounding Box) collision detection
- AI opponent with difficulty-based tracking precision
- Real-time keyboard input handling (INT 16h)
- Dynamic UI rendering with cursor positioning

**Difficulty Settings:**
| Difficulty | Ball Speed | Paddle Height | AI Precision |
|------------|------------|---------------|--------------|
| Easy       | 3          | 40px          | Relaxed      |
| Medium     | 4          | 32px          | Moderate     |
| Hard       | 5          | 24px          | Aggressive   |

**Controls:**
- **Player Paddle:** W/S keys (move up/down)
- **Menu Navigation:** Number keys 1-3 (select difficulty)
- **Restart:** R key (after game over)
- **Main Menu:** E key (return from game over)
- **Exit:** ESC key (from main menu)

---

## Compilation & Execution

### Requirements
- MASM (Microsoft Macro Assembler) or TASM
- DOSBox (for modern systems)

### Compiling
```bash
# For MASM
masm filename.asm;
link filename.obj;

# Or use TASM
tasm filename.asm
tlink filename.obj
```

### Running
```bash
# In DOS or DOSBox
filename.exe
```

## Skills Demonstrated

- Low-level programming and memory management
- Bitwise operations and arithmetic algorithms
- DOS and BIOS interrupt handling
- Graphics programming and VGA control
- Real-time input/output processing
- Algorithm implementation (Euclidean algorithm, collision detection)